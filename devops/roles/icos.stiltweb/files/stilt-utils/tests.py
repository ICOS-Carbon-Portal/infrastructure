import traceback

from stilt_utils import sync_csv_files


def test_cli(cli_runner):
    r = cli_runner.invoke(sync_csv_files.cli)
    assert r.exit_code == 2, traceback.print_exception(*r.exc_info)
