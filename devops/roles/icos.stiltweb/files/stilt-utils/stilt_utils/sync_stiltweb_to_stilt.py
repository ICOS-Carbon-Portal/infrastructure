# Sync (by hardlinking!) stilt data from new-style slot-based directory layout
# - as used by stiltweb - to the classic stilt layout.
#
# Each new-style slot directory contain four files, but only three of those are
# synced by this script. Those three file - foot, rdata and rdatafoot - have a
# one-to-one mapping between new-style and old-style and can thus easily be
# hardlinked. The csv file however exists as one-line-per-file in the new-style
# structure and many-lines-per-file in the old-style and is not synced.
#
# This script will spawn one process per station. By default it only shows what
# would be synced, use '--help' for usage info. The script is designed to run
# as a systemd service, triggered by a timer - this way one can have access to
# newly computed stilt data in the old-style layout.

import collections
import os
import re
import sys
from concurrent import futures

import click


# UTILS
def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def same_fs(path1, path2):
    path1 = os.path.realpath(os.path.normpath(path1))
    path2 = os.path.realpath(os.path.normpath(path2))

    def get_mount(path):
        if os.path.ismount(path):
            return path
        return get_mount(os.path.dirname(path))

    return (
        os.path.exists(path1)
        and os.path.exists(path2)
        and get_mount(path1) == get_mount(path2)
    )


# CREATE STATION OBJECTS
Station = collections.namedtuple("Station", ["name", "path", "pos"])


def station_from_name(name, newroot):
    # /disk/data/stiltweb/stations/PUI
    path = os.path.join(newroot, "stations", name)
    if not os.path.exists(path):
        die(f"Could not find the '{path.name}' station in {path.parent}")
    # /disk/data/stiltweb/slots/62.91Nx027.66Ex00176
    real = os.path.realpath(path)
    # 62.91Nx027.66Ex00176
    pos = os.path.basename(real)
    return Station(name, real, pos)


def list_stations(newroot):
    sdir = os.path.join(newroot, "stations")
    if not os.path.isdir(sdir):
        die(f'Expected "{sdir}" to be a directory with station symlinks!')
    for elt in os.scandir(sdir):
        # elt.path == '/disk/data/stiltweb/stations/PUI'
        # elt.name == 'PUI'
        if elt.is_symlink():
            # /disk/data/stiltweb/slots/62.91Nx027.66Ex00176
            path = os.path.realpath(elt)
            # 62.91Nx027.66Ex00176
            pos = os.path.basename(path)
            yield Station(elt.name, path, pos)


# LIST SLOTS
def list_slots(station):
    for year in os.scandir(station.path):
        if not (year.is_dir() and re.match("[0-9]+", year.name)):
            continue
        for month in os.scandir(year.path):
            if not (month.is_dir() and re.match("[0-9]+", month.name)):
                continue
            for slot in os.scandir(month.path):
                if not (slot.is_dir() and re.match("[0-9x]+", slot.name)):
                    continue
                yield (month.path, slot)


# SYNC A STATION
SyncResult = collections.namedtuple(
    "SyncResult", ["station", "nslots", "nsyncd", "slotnames"]
)


def sync_station(oldroot, station, dryrun):
    fp_dir = os.path.join(oldroot, "Footprints", station.name)
    rd_dir = os.path.join(oldroot, "RData", station.name)

    if os.path.exists(fp_dir):
        fp_files = {e.path for e in os.scandir(fp_dir)}
    else:
        fp_files = set()
        if not dryrun:
            os.makedirs(fp_dir)

    if os.path.exists(rd_dir):
        rd_files = {e.path for e in os.scandir(rd_dir)}
    else:
        rd_files = set()
        if not dryrun:
            os.makedirs(rd_dir)

    nslots = 0
    nsyncd = 0
    slotnames = []

    new2old = (
        ("foot%s_aggreg.nc", fp_dir, fp_files, "foot"),
        (".RDatafoot%s", fp_dir, fp_files, "rdatafoot"),
        (".RData%s", rd_dir, rd_files, "rdata"),
    )

    for month, slot in list_slots(station):
        nslots += 1
        # e.g '2007x12x29x12x69.28Nx016.01Ex00005'
        datepos = f"{slot.name}x{station.pos}"
        didsync = False
        for old_name, old_dir, old_files, new_name in new2old:
            old_path = os.path.join(old_dir, old_name % datepos)
            if old_path in old_files:
                continue
            new_path = os.path.join(month, slot, new_name)
            assert old_path.startswith(oldroot)
            if not dryrun:
                os.link(new_path, old_path)
            didsync = True
        if didsync:
            nsyncd += 1
            slotnames.append(slot.name)
    return SyncResult(station, nslots, nsyncd, slotnames)


def sync_all_stations(newroot, oldroot, stations, dryrun, verbose):
    print("Syncing %d stations." % (len(stations)))
    nsyncd = 0
    with futures.ProcessPoolExecutor() as executor:
        todos = {}
        for station in stations:
            future = executor.submit(sync_station, oldroot, station, dryrun)
            todos[future] = station
        for future in futures.as_completed(todos):
            station = todos[future]
            try:
                r = future.result()
                if r.nsyncd > 0:
                    if dryrun:
                        print(
                            "%6s - %-5d slots of which %5d needs linking"
                            % (r.station.name, r.nslots, r.nsyncd)
                        )
                    else:
                        print(
                            "%6s - %-5d slots of which %5d were linked"
                            % (r.station.name, r.nslots, r.nsyncd)
                        )
                    if verbose:
                        for slot in r.slotnames:
                            print(slot)
                    nsyncd += 1
            except Exception as e:
                print(future, "failed with", e)
    print("%d out of %d stations needed syncing" % (nsyncd, len(stations)))


# MAIN
@click.command()
@click.argument(
    "newroot",
    type=click.Path(exists=True, file_okay=False, dir_okay=True),
)
@click.argument(
    "oldroot",
    type=click.Path(exists=True, file_okay=False, dir_okay=True),
)
@click.argument("restrict", nargs=-1)
@click.option("--sync", is_flag=True, help="Really sync. Default is a dry run.")
@click.option(
    "--verbose", is_flag=True, help="Output every single slot that needs syncing"
)
def cli(newroot, oldroot, restrict, sync, verbose):
    """Sync slots from new (stiltweb) to old directory style.

    \b
    NEWROOT	Stiltweb directory
    OLDROOT	Directory with old-style stilt files
    RESTRICT	Only sync these stations (instead of all)
    """

    if not same_fs(newroot, oldroot):
        die(f"{newroot} and {oldroot} needs to be on the same filesystem")

    if os.getuid() == 0:
        die("Refusing to run as root, please run as the stiltweb user")

    if restrict:
        stations = [station_from_name(n, newroot) for n in restrict]
    else:
        stations = list(list_stations(newroot))

    sync_all_stations(newroot, oldroot, stations, not sync, verbose)
