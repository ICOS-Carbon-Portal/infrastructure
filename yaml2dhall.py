#!/usr/bin/env python3
"""
yaml2dhall - Automated Ansible YAML to Dhall converter

Converts YAML files to Dhall expressions that can be rendered back to
the same YAML using `dhall-to-yaml`.

Usage:
    python3 yaml2dhall.py [input-dir] [output-dir]
    python3 yaml2dhall.py devops devops-dhall

For heterogeneous lists (e.g. role references with different extra vars),
the converter generates Dhall Type/default records with Optional fields.
Render back to YAML with:
    dhall-to-yaml < file.dhall | yq 'del(.. | select(. == null))'
"""

import os
import re
import sys
import yaml
from pathlib import Path
from collections import OrderedDict

SKIP_EXTENSIONS = frozenset({
    '.py', '.sh', '.j2', '.conf', '.service', '.timer', '.ini', '.ttf',
    '.tgz', '.der', '.json', '.html', '.xml', '.sql', '.toml', '.txt',
    '.env', '.cfg', '.gitignore', '.md', '.css', '.pem', '.crt', '.key',
})
SKIP_DIRS = frozenset({
    '__pycache__', '.git',
})
COPY_DIRS = frozenset({
    'files', 'templates', 'filter_plugins', 'lookup_plugins', 'library',
    'patches',
})


def add_yaml_constructors():
    """Register constructors for Ansible-specific YAML tags."""
    def vault_constructor(loader, node):
        return f"!vault|\n{loader.construct_scalar(node)}"

    def generic_constructor(loader, tag_suffix, node):
        if isinstance(node, yaml.ScalarNode):
            return loader.construct_scalar(node)
        elif isinstance(node, yaml.SequenceNode):
            return loader.construct_sequence(node)
        elif isinstance(node, yaml.MappingNode):
            return loader.construct_mapping(node)

    yaml.SafeLoader.add_constructor('!vault', vault_constructor)
    yaml.SafeLoader.add_constructor('!vault-encrypted', vault_constructor)
    yaml.SafeLoader.add_constructor('!unsafe', lambda l, n: l.construct_scalar(n))
    yaml.SafeLoader.add_multi_constructor('', generic_constructor)


def is_vault_encrypted(text):
    return text.strip().startswith('$ANSIBLE_VAULT')


def dhall_escape_string(s):
    """Escape a string for Dhall double-quoted text."""
    s = s.replace('\\', '\\\\')
    s = s.replace('"', '\\"')
    s = s.replace('\t', '\\t')
    s = s.replace('${', '\\${')
    return s


def dhall_escape_multiline(s):
    """Escape a string for Dhall multiline text (''...'' syntax)."""
    s = s.replace("''", "'''")
    s = s.replace('${', "''${")
    return s


def dhall_key(key):
    """Make a valid Dhall record field name."""
    s = str(key)
    if re.match(r'^[a-zA-Z_][a-zA-Z0-9_/]*$', s) and s not in DHALL_KEYWORDS:
        return s
    return f'`{s}`'


DHALL_KEYWORDS = frozenset({
    'if', 'then', 'else', 'let', 'in', 'using', 'missing', 'as',
    'Infinity', 'NaN', 'merge', 'Some', 'toMap', 'assert', 'forall',
    'with', 'True', 'False', 'Type', 'Kind', 'Sort', 'Natural',
    'Integer', 'Double', 'Text', 'Bool', 'Optional', 'List', 'None',
})


def _wrap_type(t):
    """Wrap a type in parens if it's complex (contains spaces or commas)."""
    if ' ' in t or ',' in t:
        return f'({t})'
    return t


def _split_top_level(s, sep=','):
    """Split a string on `sep`, ignoring separators inside braces/parens/backticks."""
    parts = []
    depth = 0
    in_tick = False
    cur = []
    for ch in s:
        if ch == '`':
            in_tick = not in_tick
            cur.append(ch)
        elif in_tick:
            cur.append(ch)
        elif ch in '{(':
            depth += 1
            cur.append(ch)
        elif ch in '})':
            depth -= 1
            cur.append(ch)
        elif ch == sep and depth == 0:
            parts.append(''.join(cur))
            cur = []
        else:
            cur.append(ch)
    if cur:
        parts.append(''.join(cur))
    return parts


def _parse_record_fields(type_str):
    """Parse a Dhall record type `{ a : T, b : Optional U }` into {field: type}.

    The returned type strips a leading `Optional ` so callers compare the inner
    type (a None/absent value is always acceptable).
    """
    type_str = type_str.strip()
    if type_str.startswith('{') and type_str.endswith('}'):
        type_str = type_str[1:-1].strip()
    fields = {}
    for part in _split_top_level(type_str, ','):
        part = part.strip()
        if not part:
            continue
        kv = _split_top_level(part, ':')
        if len(kv) < 2:
            continue
        key = kv[0].strip()
        if key.startswith('`') and key.endswith('`'):
            key = key[1:-1]
        val = ':'.join(kv[1:]).strip()
        if val.startswith('Optional '):
            val = val[len('Optional '):].strip()
            while val.startswith('(') and val.endswith(')'):
                val = val[1:-1].strip()
        fields[key] = val
    return fields


def _parse_record_fields_full(type_str):
    """Like _parse_record_fields but preserves the full field type.

    Keeps a leading `Optional ` so type-directed emission knows to wrap absent
    values as `None T` and present ones as `Some v`.
    """
    type_str = type_str.strip()
    if type_str.startswith('{') and type_str.endswith('}'):
        type_str = type_str[1:-1].strip()
    fields = {}
    for part in _split_top_level(type_str, ','):
        part = part.strip()
        if not part:
            continue
        kv = _split_top_level(part, ':')
        if len(kv) < 2:
            continue
        key = kv[0].strip()
        if key.startswith('`') and key.endswith('`'):
            key = key[1:-1]
        fields[key] = ':'.join(kv[1:]).strip()
    return fields


def compute_dhall_type(value, depth=0):
    """Recursively compute the Dhall type for a Python value."""
    if depth > 5:
        return 'Text'
    if value is None:
        return 'Text'
    if isinstance(value, bool):
        return 'Bool'
    if isinstance(value, int):
        return 'Natural' if value >= 0 else 'Integer'
    if isinstance(value, float):
        return 'Double'
    if isinstance(value, str):
        return 'Text'
    if isinstance(value, list):
        if not value:
            return 'List Text'
        if all(isinstance(v, str) for v in value):
            return 'List Text'
        if all(isinstance(v, bool) for v in value):
            return 'List Bool'
        if all(isinstance(v, int) and not isinstance(v, bool) for v in value):
            return 'List Natural'
        if all(isinstance(v, dict) for v in value):
            rec_type = compute_unified_record_type(value, depth + 1)
            return f'List {_wrap_type(rec_type)}'
        return 'List Text'
    if isinstance(value, dict):
        return compute_record_type(value, depth + 1)
    return 'Text'


def compute_record_type(d, depth=0):
    """Compute the Dhall record type for a dict."""
    if not d or depth > 5:
        return '{}'
    fields = []
    for k, v in d.items():
        dk = dhall_key(k)
        t = compute_dhall_type(v, depth)
        fields.append(f'{dk} : {t}')
    return '{ ' + ', '.join(fields) + ' }'


def compute_unified_record_type(dicts, depth=0):
    """Compute the unified Dhall type for a list of dicts (handles heterogeneous keys)."""
    if not dicts or depth > 5:
        return '{}'

    all_keys = list(dict.fromkeys(k for d in dicts for k in d))
    universal_keys = set(all_keys)
    for d in dicts:
        universal_keys &= set(d.keys())

    fields = []
    for k in all_keys:
        dk = dhall_key(k)
        t = common_type_for_key(k, dicts, depth)
        if k not in universal_keys:
            fields.append(f'{dk} : Optional {_wrap_type(t)}')
        else:
            fields.append(f'{dk} : {t}')
    return '{ ' + ', '.join(fields) + ' }'


def common_type_for_key(key, dicts, depth=0):
    """Determine the common Dhall type for a key across multiple dicts."""
    values = [d[key] for d in dicts if key in d and d[key] is not None]

    if not values:
        return 'Text'

    if all(isinstance(v, str) for v in values):
        return 'Text'
    if all(isinstance(v, bool) for v in values):
        return 'Bool'
    if all(isinstance(v, int) and not isinstance(v, bool) for v in values):
        return 'Natural'
    if all(isinstance(v, float) for v in values):
        return 'Double'
    if all(isinstance(v, list) for v in values):
        all_items = [item for v in values for item in v]
        if all(isinstance(i, str) for i in all_items):
            return 'List Text'
        if all(isinstance(i, dict) for i in all_items):
            return f'List {_wrap_type(compute_unified_record_type(all_items, depth + 1))}'
        return 'List Text'
    if all(isinstance(v, dict) for v in values):
        return compute_unified_record_type(values, depth + 1)

    types = set()
    for v in values:
        types.add(type(v).__name__)

    if types == {'str', 'int'} or types == {'str', 'float'}:
        return 'Text'

    # Mixed forms (e.g. Ansible module key that is sometimes a scalar string
    # and sometimes a structured dict/list). Pick the dominant representation
    # so the shared type fits the most values; the minority falls back.
    dict_vals = [v for v in values if isinstance(v, dict)]
    list_vals = [v for v in values if isinstance(v, list)]
    scalar_vals = [v for v in values
                   if isinstance(v, (str, int, float, bool))]

    if dict_vals and len(dict_vals) >= len(scalar_vals) and not list_vals:
        return compute_unified_record_type(dict_vals, depth + 1)
    if list_vals and len(list_vals) >= len(scalar_vals) and not dict_vals:
        all_items = [item for v in list_vals for item in v]
        if all_items and all(isinstance(i, dict) for i in all_items):
            return f'List {_wrap_type(compute_unified_record_type(all_items, depth + 1))}'
        return 'List Text'

    if {'list', 'str'} == types:
        return 'List Text'
    return 'Text'


# Playbook/role keys whose value is an Ansible task list (eligible for the
# shared Task type). block/always/rescue are handled separately as the inline
# block sub-record type.
TASK_LIST_KEYS = frozenset({
    'tasks', 'pre_tasks', 'post_tasks', 'handlers',
})


def value_union_kind(value):
    """Classify a value into a union (tag, kind) pair.

    kind drives how the payload type is computed; tag is the Dhall union
    alternative name. Returns None for null.
    """
    if value is None:
        return None
    if isinstance(value, bool):
        return ('Bool', 'bool')
    if isinstance(value, int):
        return ('Nat', 'nat') if value >= 0 else ('Int', 'int')
    if isinstance(value, float):
        return ('Double', 'double')
    if isinstance(value, str):
        return ('Str', 'str')
    if isinstance(value, list):
        if value and all(isinstance(x, dict) for x in value):
            return ('Records', 'records')
        return ('Texts', 'texts')
    if isinstance(value, dict):
        return ('Record', 'record')
    return ('Str', 'str')


# Maps a kind to a fixed scalar Dhall type (record kinds resolved separately).
_UNION_SCALAR_TYPE = {
    'bool': 'Bool',
    'nat': 'Natural',
    'int': 'Integer',
    'double': 'Double',
    'str': 'Text',
    'texts': 'List Text',
}


def _fits_without_lossy_coercion(value, type_str):
    """Whether a value fits a Dhall type using only structure-preserving coercion.

    Permits Ansible's safe scalar->[scalar] promotion (a string where a list is
    expected) and number<->text, but rejects dict->Text, list->Text and
    bool->Text, which lose information and instead signal the need for a union.
    """
    type_str = type_str.strip()
    while type_str.startswith('(') and type_str.endswith(')'):
        type_str = type_str[1:-1].strip()

    if isinstance(value, bool):
        return type_str == 'Bool'
    if isinstance(value, (int, float)):
        return type_str in ('Natural', 'Integer', 'Double', 'Text', 'List Text')
    if isinstance(value, str):
        return type_str in ('Text', 'List Text')
    if isinstance(value, list):
        if type_str == 'List Text':
            return all(isinstance(x, (str, int, float)) for x in value)
        if type_str.startswith('List '):
            inner = type_str[5:].strip()
            return all(_fits_without_lossy_coercion(x, inner) for x in value)
        return False
    if isinstance(value, dict):
        if not type_str.startswith('{'):
            return False
        field_types = _parse_record_fields(type_str)
        for fk, fv in value.items():
            if fv is None:
                continue
            if fk not in field_types:
                return False
            if not _fits_without_lossy_coercion(fv, field_types[fk]):
                return False
        return True
    return True


def union_type_name(field):
    """Dhall identifier for a field's union type, e.g. loop -> Poly_loop."""
    safe = re.sub(r'[^A-Za-z0-9_]', '_', str(field))
    return f'Poly_{safe}'


def render_union_type(variants):
    """Render a Dhall union type from {tag: dhall_type}, tags sorted."""
    parts = [f'{tag} : {variants[tag]}' for tag in sorted(variants)]
    return '< ' + ' | '.join(parts) + ' >'


def coerce_value(value, target_type):
    """Coerce a value to match the target Dhall type."""
    if target_type == 'List Text' and isinstance(value, str):
        return [value]
    if target_type == 'Text' and isinstance(value, (int, float)):
        return str(value)
    if target_type == 'Text' and isinstance(value, bool):
        return str(value).lower()
    if target_type == 'Text' and isinstance(value, list):
        return ', '.join(str(v) for v in value)
    if target_type == 'Text' and isinstance(value, dict):
        parts = []
        for k, v in value.items():
            parts.append(f'{k}={v}' if v is not None else str(k))
        return ' '.join(parts)
    return value


class DhallConverter:
    def __init__(self):
        self.stats = {
            'converted': 0,
            'skipped': 0,
            'errors': 0,
            'vault': 0,
        }
        self.errors = []
        self._record_list_depth = 0
        self._pending_global_items = None
        self._dict_type_context = None
        self._shared_task_keys = []
        self._shared_unions = {}
        self._active_task_import = None
        self._task_import_used = False

    def convert_value(self, value, indent=0):
        """Convert a Python value (from YAML) to a Dhall expression string."""
        if value is None:
            return 'None Text'

        if isinstance(value, bool):
            return 'True' if value else 'False'

        if isinstance(value, int):
            if value < 0:
                return str(value)
            return str(value)

        if isinstance(value, float):
            if value != value:  # NaN
                return 'NaN'
            if value == float('inf'):
                return 'Infinity'
            if value == float('-inf'):
                return '-Infinity'
            return str(value)

        if isinstance(value, str):
            return self._convert_string(value, indent)

        if isinstance(value, list):
            return self._convert_list(value, indent)

        if isinstance(value, dict):
            ctx = self._dict_type_context
            self._dict_type_context = None
            if ctx:
                return self._convert_dict_with_type(value, indent, ctx)
            return self._convert_dict(value, indent)

        return f'"{dhall_escape_string(str(value))}"'

    def _convert_string(self, s, indent):
        """Convert a string to Dhall Text literal."""
        if '\n' in s:
            return self._convert_multiline_string(s, indent)
        return f'"{dhall_escape_string(s)}"'

    def _convert_multiline_string(self, s, indent):
        """Convert a multiline string to Dhall ''...'' syntax."""
        pad = '  ' * (indent + 1)
        escaped = dhall_escape_multiline(s)
        lines = escaped.split('\n')
        result = "''\n"
        for line in lines:
            if line:
                result += f'{pad}{line}\n'
            else:
                result += '\n'
        result += f'{"  " * indent}\'\''
        return result

    def _convert_list(self, lst, indent):
        """Convert a list to a Dhall expression."""
        if not lst:
            return '[] : List Text'

        pad = '  ' * indent
        ipad = '  ' * (indent + 1)

        if all(isinstance(v, str) for v in lst):
            return self._format_simple_list(lst, indent)

        if all(isinstance(v, (int, float)) and not isinstance(v, bool) for v in lst):
            items = [self.convert_value(v, indent + 1) for v in lst]
            return f'[ {", ".join(items)} ]'

        if all(isinstance(v, bool) for v in lst):
            items = [self.convert_value(v, indent + 1) for v in lst]
            return f'[ {", ".join(items)} ]'

        if all(isinstance(v, dict) for v in lst):
            return self._convert_record_list(lst, indent)

        items = []
        for v in lst:
            items.append(self.convert_value(v, indent + 1))

        if len(items) <= 3 and all(len(i) < 40 for i in items):
            return f'[ {", ".join(items)} ]'

        formatted = [f'{ipad}, {item}' for item in items]
        formatted[0] = f'{ipad}  {items[0]}'
        return f'[\n' + '\n'.join(formatted) + f'\n{pad}]'

    def _format_simple_list(self, strings, indent):
        """Format a list of strings."""
        pad = '  ' * indent
        ipad = '  ' * (indent + 1)
        items = [self._convert_string(s, indent + 1) for s in strings]
        has_multiline = any('\n' in i for i in items)
        total = sum(len(i) for i in items) + 2 * len(items)
        if not has_multiline and total < 80 and len(items) <= 4:
            return f'[ {", ".join(items)} ]'
        formatted = [f'{ipad}, {item}' for item in items]
        formatted[0] = f'{ipad}  {items[0]}'
        return f'[\n' + '\n'.join(formatted) + f'\n{pad}]'

    def _convert_record_list(self, dicts, indent):
        """Convert a list of dicts. Handle heterogeneous keys with Optional."""
        if not dicts:
            return '[] : List {}'

        self._record_list_depth += 1
        global_override = self._pending_global_items
        self._pending_global_items = None

        try:
            type_dicts = global_override if global_override else dicts

            pad = '  ' * indent
            ipad = '  ' * (indent + 1)

            all_keys = list(dict.fromkeys(k for d in type_dicts for k in d))

            universal_keys = set(all_keys)
            for d in type_dicts:
                universal_keys &= set(d.keys())

            optional_keys = [k for k in all_keys if k not in universal_keys]

            key_types = {}
            for k in all_keys:
                key_types[k] = common_type_for_key(k, type_dicts, depth=0)

            if not optional_keys:
                dict_contexts = self._compute_field_dict_contexts(
                    type_dicts, all_keys)
                field_global_items = {}
                for k in all_keys:
                    all_nested = []
                    for d in type_dicts:
                        v = d.get(k)
                        if (isinstance(v, list) and v
                                and all(isinstance(x, dict) for x in v)):
                            all_nested.extend(v)
                    if len(all_nested) > len(max(
                            (d.get(k, []) for d in type_dicts
                             if isinstance(d.get(k), list)),
                            key=lambda x: len(x) if x else 0, default=[])):
                        field_global_items[k] = all_nested

                if dict_contexts or field_global_items:
                    items = []
                    for d in dicts:
                        fields = []
                        for k in all_keys:
                            dk = dhall_key(k)
                            t = key_types[k]
                            v = coerce_value(d.get(k), t)
                            if (k in field_global_items
                                    and isinstance(v, list)):
                                self._pending_global_items = (
                                    field_global_items[k])
                            converted = self._convert_value_with_dict_ctx(
                                v, indent + 2, k, dict_contexts)
                            self._pending_global_items = None
                            fields.append(f'{dk} = {converted}')
                        entry_pad = '  ' * (indent + 2)
                        record_str = '{ ' + ', '.join(fields) + ' }'
                        if len(record_str) > 90:
                            record_str = (
                                '{\n'
                                + ',\n'.join(
                                    f'{entry_pad}  {f}' for f in fields)
                                + f'\n{entry_pad}}}'
                            )
                        items.append(record_str)
                else:
                    items = [self._convert_dict(d, indent + 1)
                             for d in dicts]
                formatted = [f'{ipad}, {item}' for item in items]
                formatted[0] = f'{ipad}  {items[0]}'
                return f'[\n' + '\n'.join(formatted) + f'\n{pad}]'

            if self._record_list_depth > 1:
                return self._inline_record_list(
                    dicts, indent, all_keys, universal_keys, key_types,
                    type_dicts)

            field_global_items = {}
            for k in all_keys:
                all_nested = []
                for d in dicts:
                    v = d.get(k)
                    if isinstance(v, list) and v and all(isinstance(x, dict) for x in v):
                        all_nested.extend(v)
                if all_nested:
                    field_global_items[k] = all_nested

            type_name = self._generate_type_name(all_keys, dicts)

            type_fields = []
            default_fields = []
            for k in all_keys:
                dk = dhall_key(k)
                t = key_types[k]
                if k in universal_keys:
                    type_fields.append(f'{dk} : {t}')
                else:
                    type_fields.append(f'{dk} : Optional {_wrap_type(t)}')
                    default_fields.append(f'{dk} = None {_wrap_type(t)}')

            type_pad = '  ' * (indent + 2)
            type_def = '{ ' + f'\n{type_pad}, '.join(type_fields) + f'\n{"  " * (indent + 1)}}}'
            default_def = '{ ' + f'\n{type_pad}, '.join(default_fields) + f'\n{"  " * (indent + 1)}}}'

            let_block = (
                f'let {type_name} =\n'
                f'{ipad}  {{ Type =\n'
                f'{ipad}      {type_def}\n'
                f'{ipad}  , default =\n'
                f'{ipad}      {default_def}\n'
                f'{ipad}  }}\n\n'
            )

            dict_contexts = self._compute_field_dict_contexts(
                type_dicts, all_keys)

            items = []
            for d in dicts:
                fields_for_item = []
                for k in all_keys:
                    dk = dhall_key(k)
                    if k in universal_keys:
                        t = key_types[k]
                        v = coerce_value(d.get(k), t)
                        if k in field_global_items and isinstance(v, list):
                            self._pending_global_items = field_global_items[k]
                        fields_for_item.append(
                            f'{dk} = {self._convert_value_with_dict_ctx(v, indent + 2, k, dict_contexts)}')
                        self._pending_global_items = None
                    elif k in d:
                        t = key_types[k]
                        v = coerce_value(d[k], t)
                        if v is None:
                            pass
                        else:
                            if k in field_global_items and isinstance(v, list):
                                self._pending_global_items = field_global_items[k]
                            converted = self._convert_value_with_dict_ctx(
                                v, indent + 2, k, dict_contexts)
                            self._pending_global_items = None
                            fields_for_item.append(
                                f'{dk} = Some {self._wrap_expr(converted)}')

                entry_pad = '  ' * (indent + 2)
                record_str = '{ ' + f', '.join(fields_for_item) + ' }'
                if len(record_str) > 90:
                    record_str = (
                        '{\n'
                        + ',\n'.join(f'{entry_pad}  {f}' for f in fields_for_item)
                        + f'\n{entry_pad}}}'
                    )

                items.append(f'{type_name}::{record_str}')

            formatted = [f'{ipad}, {item}' for item in items]
            formatted[0] = f'{ipad}  {items[0]}'
            list_str = f'[\n' + '\n'.join(formatted) + f'\n{pad}]'

            return let_block + f'{pad}in  {list_str}'

        finally:
            self._record_list_depth -= 1

    def _inline_record_list(self, dicts, indent, all_keys, universal_keys,
                            key_types, type_dicts=None):
        """Generate a heterogeneous list as expanded inline records (no let block).

        Used for nested lists to avoid type mismatches with the outer annotation.
        All Optional fields are explicitly set to None when absent.
        """
        pad = '  ' * indent
        ipad = '  ' * (indent + 1)

        if type_dicts is None:
            type_dicts = dicts
        dict_contexts = self._compute_field_dict_contexts(type_dicts, all_keys)

        items = []
        for d in dicts:
            fields = []
            for k in all_keys:
                dk = dhall_key(k)
                t = key_types[k]
                if k in d and d[k] is not None:
                    v = coerce_value(d[k], t)
                    converted = self._convert_value_with_dict_ctx(
                        v, indent + 2, k, dict_contexts)
                    if k in universal_keys:
                        fields.append(f'{dk} = {converted}')
                    else:
                        fields.append(f'{dk} = Some {self._wrap_expr(converted)}')
                else:
                    if k in universal_keys:
                        fields.append(f'{dk} = None {_wrap_type(t)}')
                    else:
                        fields.append(f'{dk} = None {_wrap_type(t)}')

            entry_pad = '  ' * (indent + 2)
            record_str = '{ ' + ', '.join(fields) + ' }'
            if len(record_str) > 90:
                record_str = (
                    '{\n'
                    + ',\n'.join(f'{entry_pad}  {f}' for f in fields)
                    + f'\n{entry_pad}}}'
                )
            items.append(record_str)

        formatted = [f'{ipad}, {item}' for item in items]
        formatted[0] = f'{ipad}  {items[0]}'
        return f'[\n' + '\n'.join(formatted) + f'\n{pad}]'

    def _convert_dict(self, d, indent):
        """Convert a dict to a Dhall record."""
        if not d:
            return '{=}'

        pad = '  ' * indent
        ipad = '  ' * (indent + 1)

        entries = []
        has_nested_let = False
        let_blocks = []
        record_entries = []

        for k, v in d.items():
            dk = dhall_key(str(k))

            # Playbook task-list fields (tasks/pre_tasks/handlers/...) reuse the
            # shared Task type when available and the tasks fit it.
            if (k in TASK_LIST_KEYS and self._active_task_import
                    and self._shared_task_keys
                    and isinstance(v, list) and v
                    and all(isinstance(x, dict) for x in v)
                    and self._tasks_fit_shared_type(v)):
                self._task_import_used = True
                record_entries.append(
                    f'{dk} = {self._emit_task_items(v, indent + 1)}')
                continue

            converted = self.convert_value(v, indent + 1)

            if converted.startswith('let '):
                parts = converted.rsplit('\n', 1)
                if len(parts) == 2 and 'in ' in parts[-1]:
                    let_part = '\n'.join(converted.split('\n')[:-1])
                    in_part = converted.split('\n')[-1].strip()
                    if in_part.startswith('in '):
                        in_part = in_part[3:].strip()
                    let_blocks.append(let_part)
                    record_entries.append(f'{dk} = {in_part}')
                    has_nested_let = True
                    continue

            record_entries.append(f'{dk} = {converted}')

        if has_nested_let:
            result = '\n'.join(let_blocks) + '\n\n'
            formatted = [f'{ipad}{e}' for e in record_entries]
            result += f'{pad}in  {{\n' + ',\n'.join(formatted) + f'\n{pad}}}'
            return result

        total = sum(len(e) for e in record_entries) + 4
        if total < 80 and len(record_entries) <= 3 and not any('\n' in e for e in record_entries):
            return '{ ' + ', '.join(record_entries) + ' }'

        formatted = [f'{ipad}, {e}' for e in record_entries]
        formatted[0] = f'{ipad}  {record_entries[0]}'
        return '{\n' + '\n'.join(formatted) + f'\n{pad}}}'

    def _convert_dict_with_type(self, d, indent, all_dicts_for_field):
        """Convert a dict, expanding Optional fields to match a unified type."""
        all_keys = list(dict.fromkeys(k for dv in all_dicts_for_field for k in dv))
        universal_keys = set(all_keys)
        for dv in all_dicts_for_field:
            universal_keys &= set(dv.keys())

        if universal_keys == set(all_keys):
            return self._convert_dict(d, indent)

        key_types = {}
        for k in all_keys:
            key_types[k] = common_type_for_key(k, all_dicts_for_field, depth=0)

        pad = '  ' * indent
        ipad = '  ' * (indent + 1)
        fields = []
        for k in all_keys:
            dk = dhall_key(k)
            t = key_types[k]
            if k in d and d[k] is not None:
                v = coerce_value(d[k], t)
                converted = self.convert_value(v, indent + 1)
                if k in universal_keys:
                    fields.append(f'{dk} = {converted}')
                else:
                    fields.append(f'{dk} = Some {self._wrap_expr(converted)}')
            else:
                fields.append(f'{dk} = None {_wrap_type(t)}')

        total = sum(len(f) for f in fields) + 4
        if total < 80 and len(fields) <= 3 and not any('\n' in f for f in fields):
            return '{ ' + ', '.join(fields) + ' }'

        formatted = [f'{ipad}, {f}' for f in fields]
        formatted[0] = f'{ipad}  {fields[0]}'
        return '{\n' + '\n'.join(formatted) + f'\n{pad}}}'

    def _compute_field_dict_contexts(self, dicts, all_keys):
        """For each field that has heterogeneous dict values across items,
        collect all dict values so nested conversion can use the unified type."""
        contexts = {}
        for k in all_keys:
            dict_values = [d[k] for d in dicts
                           if k in d and isinstance(d[k], dict)]
            if len(dict_values) < 2:
                continue
            all_sub_keys = set(sk for dv in dict_values for sk in dv)
            shared = set(dict_values[0].keys())
            for dv in dict_values[1:]:
                shared &= set(dv.keys())
            if all_sub_keys != shared:
                contexts[k] = dict_values
        return contexts

    def _convert_value_with_dict_ctx(self, value, indent, field_name,
                                     dict_contexts):
        """Convert a value, setting dict type context if needed."""
        if field_name in dict_contexts and isinstance(value, dict):
            self._dict_type_context = dict_contexts[field_name]
        result = self.convert_value(value, indent)
        self._dict_type_context = None
        return result

    def _generate_type_name(self, keys, dicts):
        """Generate a Dhall type name for a heterogeneous list."""
        if all('role' in d for d in dicts):
            return 'Role'
        if all('name' in d for d in dicts):
            if any('import_role' in d for d in dicts):
                return 'Task'
            if any('apt' in d or 'shell' in d or 'copy' in d for d in dicts):
                return 'Task'
            return 'Entry'
        if all('hosts' in d for d in dicts):
            return 'Play'
        return 'Item'

    def _wrap_expr(self, expr):
        """Wrap in parens if needed for Some/None."""
        expr = expr.strip()
        if (expr.startswith('"') or expr.startswith("''")
                or expr.startswith('[') or expr.startswith('{')
                or expr in ('True', 'False', 'NaN', 'Infinity')
                or re.match(r'^-?\d', expr)):
            return expr
        return f'({expr})'

    def set_shared_task_type(self, all_tasks):
        """Pre-compute shared task type info from all collected task items."""
        all_keys = sorted(dict.fromkeys(k for d in all_tasks for k in d))
        key_types = {}
        for k in all_keys:
            key_types[k] = common_type_for_key(k, all_tasks, depth=0)
        self._shared_task_keys = all_keys
        self._shared_task_types = key_types
        self._shared_task_count = len(all_tasks)
        dict_values_by_key = {}
        for k in all_keys:
            dicts = [d[k] for d in all_tasks
                     if k in d and isinstance(d[k], dict)]
            if len(dicts) >= 1:
                dict_values_by_key[k] = dicts
        self._shared_task_dict_ctx = dict_values_by_key

        # Collect all block/always/rescue sub-tasks globally so nested task
        # lists expand to match the shared type's unified sub-record type.
        self._shared_subtasks = {}
        for sub_key in ('block', 'always', 'rescue'):
            collected = []
            for d in all_tasks:
                v = d.get(sub_key)
                if isinstance(v, list) and all(isinstance(x, dict) for x in v):
                    collected.extend(v)
            if collected:
                self._shared_subtasks[sub_key] = collected

        # Detect polymorphic fields: those whose values can't all be coerced to
        # a single Dhall type. These become union types so any Ansible form is
        # representable (dhall-to-yaml renders union payloads transparently).
        self._shared_unions = {}            # field -> {tag: dhall_type}
        self._shared_union_payload = {}     # field -> {tag: [dicts]} for records
        for k in all_keys:
            if k in ('block', 'always', 'rescue'):
                continue
            values = [d[k] for d in all_tasks if k in d and d[k] is not None]
            t = key_types[k]
            if all(_fits_without_lossy_coercion(v, t) for v in values):
                continue  # fits the common type cleanly; no union needed

            variants = {}
            record_items = {}
            for v in values:
                kind = value_union_kind(v)
                if kind is None:
                    continue
                tag, knd = kind
                if knd == 'records':
                    record_items.setdefault(tag, []).extend(v)
                elif knd == 'record':
                    record_items.setdefault(tag, []).append(v)
                else:
                    variants[tag] = _UNION_SCALAR_TYPE[knd]
            for tag, items in record_items.items():
                rec = compute_unified_record_type(items, depth=1)
                if tag == 'Records':
                    variants[tag] = f'List {_wrap_type(rec)}'
                else:
                    variants[tag] = rec
            if len(variants) >= 2:
                self._shared_unions[k] = variants
                if record_items:
                    self._shared_union_payload[k] = record_items

    def render_shared_task_type(self):
        """Render the shared Task type as a Dhall Type/default record.

        Uses the same key_types computed in set_shared_task_type so the type
        file on disk always matches the values the converter generates.
        """
        all_keys = self._shared_task_keys
        unions = self._shared_unions

        # Field type is the union (if polymorphic) or the plain common type.
        def field_type(k):
            if k in unions:
                return union_type_name(k)
            return _wrap_type(self._shared_task_types[k])

        type_lines = []
        default_lines = []
        for k in all_keys:
            dk = dhall_key(k)
            ft = field_type(k)
            type_lines.append(f'  , {dk} : Optional {ft}')
            default_lines.append(f'  , {dk} = None {ft}')
        if type_lines:
            type_lines[0] = type_lines[0].replace(', ', '  ', 1)
            default_lines[0] = default_lines[0].replace(', ', '  ', 1)
        type_block = '\n'.join(type_lines)
        default_block = '\n'.join(default_lines)

        # Union type definitions + exports so task files can construct values
        # as `Task.Poly_<field>.<Tag> payload`.
        union_defs = ''
        export_lines = ''
        for k in sorted(unions):
            name = union_type_name(k)
            union_defs += f'let {name} = {render_union_type(unions[k])}\n\n'
            export_lines += f', {name} = {name}\n'

        n_tasks = self._shared_task_count
        n_unions = len(unions)
        record = (
            '{ Type =\n'
            '  {\n'
            f'{type_block}\n'
            '  }\n'
            ', default =\n'
            '  {\n'
            f'{default_block}\n'
            '  }\n'
            f'{export_lines}'
            '}\n'
        )
        return (
            '-- Shared Ansible task type, auto-generated from all role '
            'task/handler files.\n'
            f'-- Covers {n_tasks} task items across {len(all_keys)} unique '
            'fields. Every field is\n'
            '-- Optional so any single task uses only the keys it needs '
            '(`Task::{ ... }`).\n'
            f'-- {n_unions} polymorphic fields are union types '
            '(e.g. `loop`, `file`); construct with\n'
            '-- `Task.Poly_<field>.<Tag> value`. dhall-to-yaml renders the '
            'payload transparently.\n'
            '--\n'
            '-- Usage from a role task file:\n'
            '--   let Task = ../../../types/Task.dhall\n'
            '--   in [ Task::{ name = Some "Install", apt = Some { ... } } ]\n'
            '\n'
            + (f'{union_defs}in  {record}' if union_defs else record)
        )

    def convert_file(self, yaml_path, task_import_path=None, source_label=None):
        """Convert a YAML file to Dhall. Returns (dhall_text, warnings).

        If task_import_path is set, the file is a role task/handler file and
        should use a shared Task type import. source_label is the path shown in
        the "Auto-generated from" header (defaults to the bare filename).
        """
        try:
            text = yaml_path.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            return None, [f'Binary file, skipping: {yaml_path}']

        if is_vault_encrypted(text):
            self.stats['vault'] += 1
            return None, [f'Vault-encrypted, skipping: {yaml_path}']

        if not text.strip():
            return '{=}\n', []

        try:
            docs = list(yaml.safe_load_all(text))
        except yaml.YAMLError as e:
            self.stats['errors'] += 1
            return None, [f'YAML parse error in {yaml_path}: {e}']

        docs = [d for d in docs if d is not None]

        if not docs:
            return '{=}\n', []

        warnings = []
        header = f'-- Auto-generated from {source_label or yaml_path.name}\n'

        # Make the shared Task import available to this file's conversion; nested
        # playbook task-lists pick it up via _convert_dict.
        self._active_task_import = task_import_path
        self._task_import_used = False

        # A role task/handler file whose top-level document is itself a task list.
        if (task_import_path and self._shared_task_keys
                and len(docs) == 1 and isinstance(docs[0], list)
                and docs[0] and all(isinstance(d, dict) for d in docs[0])
                and self._tasks_fit_shared_type(docs[0])):
            result = self._convert_task_list_with_shared_type(
                docs[0], task_import_path)
            result = header + '\n' + result + '\n'
            self.stats['converted'] += 1
            self.stats.setdefault('shared_type', 0)
            self.stats['shared_type'] += 1
            return result, warnings

        if len(docs) == 1:
            body = self.convert_value(docs[0], 0)
        else:
            body = self.convert_value(docs, 0)

        # If a nested task-list used the shared type, add the import preamble.
        if self._task_import_used and task_import_path:
            result = f'let Task = {task_import_path}\n\nin  {body}'
            self.stats.setdefault('shared_type', 0)
            self.stats['shared_type'] += 1
        else:
            result = body

        result = header + '\n' + result + '\n'
        self.stats['converted'] += 1
        return result, warnings

    def _tasks_fit_shared_type(self, tasks):
        """Check every task's fields are representable by the shared Task type."""
        for d in tasks:
            for k, v in d.items():
                if v is None:
                    continue
                if k in ('block', 'always', 'rescue'):
                    # Sub-tasks are converted against the globally-unified block
                    # sub-type, so they fit by construction; verify only that
                    # their fields/kinds are covered by that global sub-type.
                    if isinstance(v, list) and all(isinstance(x, dict) for x in v):
                        if not self._subtasks_fit(k, v):
                            return False
                    continue
                if k not in self._shared_task_types:
                    return False
                if k in self._shared_unions:
                    # Union must have a matching alternative whose type also
                    # fully covers this value (e.g. all record sub-keys).
                    kind = value_union_kind(v)
                    if not kind or kind[0] not in self._shared_unions[k]:
                        return False
                    variant_type = self._shared_unions[k][kind[0]]
                    if not self._value_fits_type(v, variant_type):
                        return False
                    continue
                if not self._value_fits_type(v, self._shared_task_types[k]):
                    return False
        return True

    def _subtasks_fit(self, sub_key, subtasks):
        """Check block/always/rescue sub-tasks fit the global sub-type.

        The sub-type is computed (per field) from every block sub-task across
        all files, matching how the values are emitted; a value only fails if
        the field is polymorphic within blocks (which blocks don't union-ise).
        """
        global_items = self._shared_subtasks.get(sub_key, subtasks)
        sub_keys = set(k for d in global_items for k in d)
        for d in subtasks:
            for k, v in d.items():
                if v is None or k not in sub_keys:
                    continue
                t = common_type_for_key(k, global_items, depth=0)
                if not self._value_fits_type(coerce_value(v, t), t):
                    return False
        return True

    def _value_fits_type(self, value, type_str):
        """Check a Python value can be faithfully represented as a Dhall type."""
        type_str = type_str.strip()
        while type_str.startswith('(') and type_str.endswith(')'):
            type_str = type_str[1:-1].strip()

        if type_str == 'Text':
            # scalars only; coercing list/dict to Text would lose structure
            return isinstance(value, (str, int, float, bool))
        if type_str == 'Bool':
            return isinstance(value, bool)
        if type_str in ('Natural', 'Integer'):
            return isinstance(value, int) and not isinstance(value, bool)
        if type_str == 'Double':
            return isinstance(value, (int, float)) and not isinstance(value, bool)
        if type_str == 'List Text':
            if isinstance(value, str):
                return True
            if isinstance(value, list):
                return all(isinstance(x, (str, int, float, bool)) for x in value)
            return False
        if type_str.startswith('List '):
            inner = type_str[5:].strip()
            if not isinstance(value, list):
                return False
            return all(self._value_fits_type(x, inner) for x in value)
        if type_str.startswith('{'):
            # record type
            if not isinstance(value, dict):
                return False
            field_types = _parse_record_fields(type_str)
            for fk, fv in value.items():
                if fv is None:
                    continue
                if fk not in field_types:
                    return False
                if not self._value_fits_type(fv, field_types[fk]):
                    return False
            return True
        return True

    def _emit_typed(self, value, type_str, indent):
        """Emit a value as a Dhall expression matching `type_str` exactly.

        Type-directed: records get every field (Some/None per the type), nested
        records/lists recurse, so output always matches the shared annotation.
        """
        type_str = type_str.strip()
        while type_str.startswith('(') and type_str.endswith(')'):
            type_str = type_str[1:-1].strip()

        if type_str.startswith('Optional '):
            inner = type_str[len('Optional '):].strip()
            if value is None:
                return f'None {_wrap_type(inner)}'
            return f'Some {self._wrap_expr(self._emit_typed(value, inner, indent))}'

        if type_str.startswith('{') and isinstance(value, dict):
            field_types = _parse_record_fields_full(type_str)
            pad = '  ' * indent
            ipad = '  ' * (indent + 1)
            parts = []
            for fk, ftype in field_types.items():
                # find the source value for this field (keys may be backticked)
                if fk in value:
                    fv = value[fk]
                else:
                    fv = None
                parts.append(f'{dhall_key(fk)} = '
                             f'{self._emit_typed(fv, ftype, indent + 1)}')
            inline = '{ ' + ', '.join(parts) + ' }'
            if len(inline) <= 90 and '\n' not in inline:
                return inline
            body = ',\n'.join(f'{ipad}  {p}' for p in parts)
            return '{\n' + body + f'\n{pad}}}'

        if type_str == 'List Text':
            items = value if isinstance(value, list) else [value]
            items = [x if isinstance(x, str) else str(x) for x in items]
            return self.convert_value(items, indent)

        if type_str.startswith('List '):
            inner = type_str[len('List '):].strip()
            if not isinstance(value, list):
                value = [value]
            if not value:
                return f'[] : {type_str}'
            pad = '  ' * indent
            ipad = '  ' * (indent + 1)
            elems = [self._emit_typed(x, inner, indent + 1) for x in value]
            formatted = [f'{ipad}, {e}' for e in elems]
            formatted[0] = f'{ipad}  {elems[0]}'
            return '[\n' + '\n'.join(formatted) + f'\n{pad}]'

        # scalar leaf — reuse the standard coercion + literal emitter
        return self.convert_value(coerce_value(value, type_str), indent)

    def _convert_task_item_fields(self, d, indent):
        """Convert a single task dict's fields using the shared type."""
        fields = []
        for k, v in d.items():
            if v is None:
                continue
            dk = dhall_key(k)
            t = self._shared_task_types.get(k, 'Text')

            if (isinstance(v, list) and v
                    and all(isinstance(x, dict) for x in v)
                    and k in ('block', 'always', 'rescue')):
                global_sub = self._shared_subtasks.get(k)
                if global_sub:
                    self._pending_global_items = global_sub
                sub_items = self._convert_sub_task_list(v, indent + 1)
                self._pending_global_items = None
                fields.append(f'{dk} = Some ({sub_items})')
                continue

            if k in self._shared_unions:
                fields.append(
                    f'{dk} = Some ({self._convert_union_value(k, v, indent + 1)})')
                continue

            emitted = self._emit_typed(v, t, indent + 1)
            wrapped = self._wrap_expr(emitted)
            if wrapped.startswith('let ') or '\nlet ' in wrapped:
                wrapped = f'({wrapped})'
            fields.append(f'{dk} = Some {wrapped}')
        return fields

    def _convert_union_value(self, key, value, indent):
        """Emit a polymorphic field value as `Task.Poly_<key>.<Tag> payload`."""
        uname = union_type_name(key)
        tag, knd = value_union_kind(value)
        variant_type = self._shared_unions[key][tag]

        # Type-directed emission against the chosen variant's type, so record
        # payloads match the union alternative exactly (all fields, nesting).
        payload = self._emit_typed(value, variant_type, indent + 1)
        payload = self._wrap_expr(payload)
        if payload.startswith('let ') or '\nlet ' in payload:
            payload = f'({payload})'
        return f'Task.{uname}.{tag} {payload}'

    def _convert_sub_task_list(self, tasks, indent):
        """Convert a nested task list (block/always/rescue) using regular converter."""
        return self._convert_list(tasks, indent)

    def _emit_task_items(self, tasks, indent=0):
        """Emit `[ Task::{...} ]` for a task list (assumes Task is in scope)."""
        pad = '  ' * indent
        ipad = '  ' * (indent + 1)
        items = []
        for d in tasks:
            fields = self._convert_task_item_fields(d, indent + 1)
            entry_pad = '  ' * (indent + 2)
            record_str = '{ ' + ', '.join(fields) + ' }'
            if len(record_str) > 90:
                record_str = (
                    '{\n'
                    + ',\n'.join(f'{entry_pad}  {f}' for f in fields)
                    + f'\n{entry_pad}}}'
                )
            items.append(f'Task::{record_str}')
        formatted = [f'{ipad}, {item}' for item in items]
        formatted[0] = f'{ipad}  {items[0]}'
        return '[\n' + '\n'.join(formatted) + f'\n{pad}]'

    def _convert_task_list_with_shared_type(self, tasks, import_path):
        """Convert a top-level task list, with the shared Task import preamble."""
        self._task_import_used = True
        return f'let Task = {import_path}\n\nin  {self._emit_task_items(tasks, 0)}'

    def _is_role_task_list(self, data):
        """Check if a parsed YAML document is a task list usable with shared type."""
        return (isinstance(data, list) and data
                and all(isinstance(d, dict) for d in data))


def _collect_role_tasks(input_path):
    """Collect every Ansible task item the shared Task type must cover.

    Includes role tasks/handlers files (whose top-level document is a task
    list) and playbook task-list fields (tasks/pre_tasks/post_tasks/handlers
    inside plays), so the shared type and its unions are trained on all the
    tasks they will actually be applied to.
    """
    import yaml as _yaml
    all_tasks = []
    for root, dirs, files in os.walk(input_path):
        if '.git' in root.split(os.sep):
            continue
        for fname in sorted(files):
            if not fname.endswith(('.yml', '.yaml')):
                continue
            fpath = os.path.join(root, fname)
            try:
                text = open(fpath).read()
                if text.strip().startswith('$ANSIBLE_VAULT'):
                    continue
                for doc in _yaml.safe_load_all(text):
                    if not isinstance(doc, list):
                        continue
                    if not all(isinstance(d, dict) for d in doc):
                        continue
                    parts = Path(root).parts
                    if parts and parts[-1] in ('tasks', 'handlers'):
                        # bare task list (role tasks/handlers file)
                        all_tasks.extend(doc)
                    else:
                        # playbook: pull task lists out of each play
                        for play in doc:
                            for key in TASK_LIST_KEYS:
                                tl = play.get(key)
                                if (isinstance(tl, list) and tl
                                        and all(isinstance(x, dict) for x in tl)):
                                    all_tasks.extend(tl)
            except Exception:
                continue
    return all_tasks


def convert_directory(input_dir, output_dir):
    """Convert all YAML files in input_dir to Dhall in output_dir."""
    input_path = Path(input_dir).resolve()
    output_path = Path(output_dir).resolve()

    add_yaml_constructors()
    converter = DhallConverter()

    print('Collecting role tasks for shared type...')
    all_tasks = _collect_role_tasks(input_path)
    if all_tasks:
        converter.set_shared_task_type(all_tasks)
        print(f'  {len(all_tasks)} task items, '
              f'{len(converter._shared_task_keys)} fields')
        type_file = output_path / 'types' / 'Task.dhall'
        type_file.parent.mkdir(parents=True, exist_ok=True)
        type_file.write_text(converter.render_shared_task_type(),
                             encoding='utf-8')
        print(f'  wrote shared type to {type_file.relative_to(output_path)}')

    all_warnings = []

    for root, dirs, files in os.walk(input_path):
        rel_root = Path(root).relative_to(input_path)

        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]

        skip_this_dir = False
        for part in rel_root.parts:
            if part in COPY_DIRS:
                skip_this_dir = True
                break

        if skip_this_dir:
            converter.stats['skipped'] += len(files)
            continue

        for fname in sorted(files):
            fpath = Path(root) / fname

            ext = fpath.suffix.lower()

            if ext in SKIP_EXTENSIONS:
                converter.stats['skipped'] += 1
                continue

            if fname in ('justfile', 'ansible.cfg', '.gitignore', 'Makefile'):
                converter.stats['skipped'] += 1
                continue

            if ext not in ('.yml', '.yaml'):
                converter.stats['skipped'] += 1
                continue

            rel = fpath.relative_to(input_path)
            out_file = output_path / rel.with_suffix('.dhall')
            source_label = os.path.relpath(fpath, start=out_file.parent)
            # Relative import to the shared Task type, valid from any file's
            # location (role task files and playbooks alike). Dhall requires
            # relative imports to begin with ./ or ../
            task_import = os.path.relpath(
                output_path / 'types' / 'Task.dhall', start=out_file.parent)
            if not task_import.startswith('.'):
                task_import = './' + task_import

            dhall_text, warnings = converter.convert_file(
                fpath, task_import_path=task_import,
                source_label=source_label)
            all_warnings.extend(warnings)

            if dhall_text is None:
                continue

            out_file.parent.mkdir(parents=True, exist_ok=True)
            out_file.write_text(dhall_text, encoding='utf-8')

    render_script = output_path / 'render.sh'
    render_script.write_text(
        '#!/usr/bin/env bash\n'
        '# Render all Dhall files back to YAML\n'
        '# Requires: dhall-to-yaml (https://github.com/dhall-lang/dhall-haskell)\n'
        '#           yq (https://github.com/mikefarah/yq)\n\n'
        'set -euo pipefail\n\n'
        'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\n'
        'OUTPUT_DIR="${1:-$SCRIPT_DIR/../devops-rendered}"\n\n'
        'mkdir -p "$OUTPUT_DIR"\n\n'
        'find "$SCRIPT_DIR" -name "*.dhall" -print0 | while IFS= read -r -d "" f; do\n'
        '  rel="${f#$SCRIPT_DIR/}"\n'
        '  out="$OUTPUT_DIR/${rel%.dhall}.yml"\n'
        '  mkdir -p "$(dirname "$out")"\n'
        '  echo "Rendering $rel -> $out"\n'
        '  dhall-to-yaml --file "$f" | yq \'del(.. | select(. == null))\' > "$out"\n'
        'done\n\n'
        'echo "Done. Output in $OUTPUT_DIR"\n',
        encoding='utf-8'
    )
    render_script.chmod(0o755)

    return converter.stats, all_warnings


def main():
    input_dir = sys.argv[1] if len(sys.argv) > 1 else 'devops'
    output_dir = sys.argv[2] if len(sys.argv) > 2 else 'devops-dhall'

    print(f'Converting {input_dir}/ -> {output_dir}/')
    stats, warnings = convert_directory(input_dir, output_dir)

    if warnings:
        print(f'\nWarnings ({len(warnings)}):')
        for w in warnings:
            print(f'  {w}')

    print(f'\nStats:')
    print(f'  Converted: {stats["converted"]}')
    print(f'  Skipped:   {stats["skipped"]}')
    print(f'  Vault:     {stats["vault"]}')
    print(f'  Errors:    {stats["errors"]}')


if __name__ == '__main__':
    main()
