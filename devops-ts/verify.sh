#!/usr/bin/env bash
# Prove that every TypeScript playbook renders to YAML semantically identical to
# the original hand-written .yml in ../devops.
#
# "Semantically identical" = the two YAML documents parse to the same data
# structure (Ansible is insensitive to key order and to scalar-style choices
# like `yes` vs `true` or folded vs plain strings).
#
# Requires: deno, python3 + pyyaml
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIG_DIR="$SCRIPT_DIR/../devops"

PASS=0
FAIL=0

for ts in "$SCRIPT_DIR"/playbooks/*.ts; do
  base="$(basename "${ts%.ts}")"
  orig="$ORIG_DIR/$base.yml"
  if [[ ! -f "$orig" ]]; then
    echo "SKIP $base (no original $orig)"
    continue
  fi

  rendered="$(deno run --quiet --allow-all "$SCRIPT_DIR/render.ts" "$ts" 2>/tmp/render.err)"
  if [[ $? -ne 0 ]]; then
    echo "FAIL $base (render error)"
    cat /tmp/render.err
    FAIL=$((FAIL + 1))
    continue
  fi

  if RENDERED="$rendered" ORIG="$orig" python3 - <<'PY'
import os, sys, yaml
rendered = yaml.safe_load(os.environ["RENDERED"])
with open(os.environ["ORIG"]) as f:
    original = yaml.safe_load(f)
sys.exit(0 if rendered == original else 1)
PY
  then
    echo "OK   $base"
    PASS=$((PASS + 1))
  else
    echo "FAIL $base (output differs)"
    FAIL=$((FAIL + 1))
  fi
done

echo
echo "Verify: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
