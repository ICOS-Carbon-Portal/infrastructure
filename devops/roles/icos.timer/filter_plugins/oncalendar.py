import re

from ansible.errors import AnsibleFilterError

WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']


class NotConvertible(Exception):
    pass


def _field(spec, maximum):
    parts = []
    for component in spec.split(','):
        m = re.fullmatch(r'(\*|\d+)(?:\.\.(\d+))?(?:/(\d+))?', component)
        if not m:
            raise NotConvertible(f'unsupported component "{component}"')
        start, end, step = m.groups()
        start = start if start == '*' else str(int(start))
        if end is not None:
            if start == '*':
                raise NotConvertible(f'unsupported component "{component}"')
            start = f'{start}-{int(end)}'
        if step is not None:
            if end is None and start != '*':
                # systemd's "a/b" repeats from a up to the field's maximum
                start = f'{start}-{maximum}'
            start = f'{start}/{int(step)}'
        parts.append(start)
    return ','.join(parts)


def _weekdays(spec):
    days = set()
    for component in spec.split(','):
        names = component.split('..')
        if len(names) > 2 or any(n not in WEEKDAYS for n in names):
            raise NotConvertible(f'unsupported weekday "{component}"')
        first = WEEKDAYS.index(names[0])
        last = WEEKDAYS.index(names[-1])
        # systemd ranges run Mon..Sun, so Sun is index 7 at the end of a range
        if len(names) == 2 and last == 0:
            last = 7
        if last < first:
            raise NotConvertible(f'unsupported weekday range "{component}"')
        days.update(d % 7 for d in range(first, last + 1))
    return ','.join(str(d) for d in sorted(days))


def oncalendar_to_cron(normalized):
    """Convert the "Normalized form" printed by systemd-analyze calendar into
    {"cron": "<5-field cron expression>", "timezone": "<tz or None>"}."""
    tokens = normalized.split()
    weekdays = '*'
    try:
        if tokens and re.match(r'[A-Z][a-z]{2}', tokens[0]):
            weekdays = _weekdays(tokens.pop(0))
        if len(tokens) not in (2, 3):
            raise NotConvertible('expected a date, a time and an optional timezone')
        date, time = tokens[0], tokens[1]
        timezone = tokens[2] if len(tokens) == 3 else None

        if '~' in date:
            raise NotConvertible('"~" (days from the end of the month) has no cron equivalent')
        year, month, day = date.split('-')
        hour, minute, second = time.split(':')
        if year != '*':
            raise NotConvertible('cron has no year field')
        if second not in ('00', '0'):
            raise NotConvertible('cron has no seconds field')

        day = _field(day, 31)
        if day != '*' and weekdays != '*':
            # systemd requires both to match; cron fires when either does
            raise NotConvertible('cron can not require both a day of month and a weekday')

        cron_expression = ' '.join([
            _field(minute, 59),
            _field(hour, 23),
            day,
            _field(month, 12),
            weekdays,
        ])
    except (NotConvertible, ValueError) as e:
        raise AnsibleFilterError(
            f'Can not convert OnCalendar "{normalized}" to a cron expression ({e})'
        )
    return {'cron': cron_expression, 'timezone': timezone}


class FilterModule(object):

    def filters(self):
        return {
            'oncalendar_to_cron': oncalendar_to_cron,
        }
