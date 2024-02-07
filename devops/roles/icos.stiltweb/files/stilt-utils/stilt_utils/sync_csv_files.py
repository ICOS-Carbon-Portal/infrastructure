# Sync csv from stilt to stiltweb.
#
# Split the large csv files output by stilt into small ones for use by
# stiltweb - overwriting the existing csv files.
#
# This script started its life as a way to populate stiltweb slots
# with csv files. The slots that existed back then only had three
# files (foot, rdata, rdatafoot) and needed a csv as well.
#
# These days all slots have csv files and newly created slots gets a
# csv as well. However, sometimes the csv files needs to be
# updated. This is done by running a classical stilt outside of
# stiltweb and then using this script to split the resulting large csv
# files into many small ones used by stiltweb.
#
# Once the stiltweb's csv files for a given station/year has been
# updated the stiltweb cache file for that station/year needs to be
# removed as well for the new csv files take effect.

import collections
import csv
import glob
import os
from pathlib import Path
import re
import sys
from concurrent import futures

import click

from .common import parse_date_id

CLICK_EXISTING_DIR = click.Path(
    path_type=Path, exists=True, file_okay=False, dir_okay=True
)

# Write files here.
STILTWEB_STATIONS = Path("/data/stiltweb/stations")

# Make sure that we read the correct csv files, the following regexp:
#   matches 'stiltresult2007x62.91Nx027.66Ex00176_2.csv'
#   but not 'stiltresult2007x62.91Nx027.66Ex00176.csv'
MATCHING_CSV = re.compile(r"stiltresult(\d{4})x[^_]+_\d+.csv")

# This object serves as something to return to the process executor.
SyncResult = collections.namedtuple(
    "SyncResult", ["csvdir", "nwritten", "nnoexist", "nskipped"]
)


def remove_csv_cache_file(station, year):
    """Remove the stiltweb csv cache file for station/year.

    Stiltweb keeps a csv cache file (consisting of the 365*(24/3) ==
    2920 small csv files that makes up a station-year). When we update
    the individual csv files we need to remove the cache
    file. Stiltweb will automatically rebuild the cache file. This
    also has the benefit of making our update atomic.
    """
    cache_files = glob.glob(
        os.path.join(STILTWEB_STATIONS, station, year, "cache*.txt")
    )
    # Check our assumptions about cache files before removing any.
    assert len(cache_files) in (0, 1), cache_files
    if len(cache_files) > 0:
        os.unlink(cache_files[0])


def open_stilt_csv(path):
    # header looks like:
    #  "ident" "latstart" "lonstart" "aglstart"
    # data looks like
    #  17349.25 69.28 16.01 5
    reader = csv.reader(open(path), delimiter=" ")
    header = next(reader, None)
    return (header, reader)


def calculate_slotdir_path(station, row):
    """Calculate the correct stiltweb slot path for a csv row.

    The first field of each csv row is the date field, parse that and
    use it to index into stiltweb's directory tree.

    >>> calculate_slotdir_path('HEI', ['17349.25', '69.28', '16.01', '5'])
    PosixPath('/data/stiltweb/stations/HEI/2007/07/2007x07x02x06')
    """
    date, slot = parse_date_id(row[0])
    if slot is None:
        return None
    slotname = "%sx%02dx%02dx%s" % (date.year, date.month, date.day, slot)
    return STILTWEB_STATIONS.joinpath(
        station, str(date.year), f"{date.month:02}", slotname
    )


def extract_csv_for_station(csvdir, station, newname):
    """Parse the large csv files for a station and write the small csv files.

    This is the main worker function for each spawned process.

    newname looks like "csv_XX3nZE3l0ODO9QA-T9gqI0GU" and contains the PID.
    """
    assert newname is None or newname.startswith("csv_")
    nnoexist = 0
    nwritten = 0
    nskipped = 0
    for f in sorted(os.scandir(csvdir), key=lambda k: k.name):
        m = MATCHING_CSV.match(f.name)
        if not m:
            continue
        header, reader = open_stilt_csv(f.path)
        nwritten_save = nwritten
        for row in reader:
            slotdir = calculate_slotdir_path(station, row)
            if slotdir is None:
                nskipped += 1
                continue
            if not slotdir.exists():
                nnoexist += 1
                continue
            destcsv = slotdir / "csv"
            if destcsv.exists():
                if newname is not None:

                    destcsv.rename(destcsv.with_name(newname))


            with open(destcsv, "w") as f:
                writer = csv.writer(f, delimiter=" ")
                writer.writerow(header)
                writer.writerow(row)

        if nwritten > nwritten_save:
            remove_csv_cache_file(station, m.group(1))
    return SyncResult(csvdir, nwritten, nnoexist, nskipped)


@click.command()
@click.argument("cvsroot", type=CLICK_EXISTING_DIR)
@click.argument("stationroot", type=CLICK_EXISTING_DIR)
@click.option("--rename", help="Rename existing csv files to this")
@click.option("--overwrite", is_flag=True, help="Remove existing csv files")
def cli(cvsroot, stationroot, rename, overwrite):
    """Syncs new csv files into the stiltweb/stations directory tree.

    CVSROOT is the directory where new (large) csv files are found.

    STATIONROOT is the stiltweb/stations directory into which csv files should
    be written

    \b
    Example
      sync-csv-files --overwrite /tmp/stiltresults /data/stiltweb/stations

    This will find all csv files in /tmp/stiltresults, break them into parts
    and move them into the directory tree at /data/stiltweb/stations. Existing
    csv files in /data/stiltweb/stations will be overwritten

    \b
    Example
      sync-csv-files --rename csv_XX3nZE3l0ODO9QA-T9gqI0GU ...

    Same as the previous example but instead of overwriting existing csv
    files, they will be renamed to csv_XX3nZE3l0ODO9QA-T9gqI0GU
    """
    if rename is None and overwrite is False:
        raise click.UsageError("Must specify one of --rename or --overwrite")

    if rename is not None and overwrite is True:
        raise click.UsageError("Use either --rename or --overwrite")

    print(rename, overwrite)
    return
    stations = []
    for csvdir in os.scandir(sys.argv[1]):
        if not csvdir.is_dir():
            continue
        assert os.path.exists(os.path.join(STILTWEB_STATIONS, csvdir.name))
        stations.append(csvdir)
    with futures.ProcessPoolExecutor() as executor:
        todos = {}
        for csvdir in stations:
            future = executor.submit(extract_csv_for_station, csvdir.path, csvdir.name)
            todos[future] = csvdir.name
        for future in futures.as_completed(todos):
            result = future.result()
            print(result)
