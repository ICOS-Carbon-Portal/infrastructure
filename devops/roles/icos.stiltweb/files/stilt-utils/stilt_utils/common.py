import datetime

# The date id column used by stilt start at this date.
ORIGIN = datetime.date(1960, 1, 1)

STILT_DATE_ID_SLOTS = {"0": "00", "125": "03", "25": "06", "375": "09",
                       "5": "12", "625": "15", "75": "18", "875": "21"}



def parse_date_id(s):
    """Parse stilt date/slot string into python objects

    Each slot is a decimal value which gives us the three-hour window
    since stilt's ORIGIN.

    >>> parse_date_id('17167.5')
    (datetime.date(2007, 1, 1), '12')
    >>> parse_date_id('20820.125')
    (datetime.date(2017, 1, 1), '03')
    """
    # '17167' => '17167.0'
    if '.' not in s:
        s += '.0'
    ndays, nslot = s.split('.')
    date = ORIGIN + datetime.timedelta(days=int(ndays))
    try:
        slot = STILT_DATE_ID_SLOTS[nslot]
    except KeyError:
        # This happens - presumably - if stilt has been run for another
        # resolution that three-hourly. nslot might look like '4583333333'.
        slot = None
    return date, slot
