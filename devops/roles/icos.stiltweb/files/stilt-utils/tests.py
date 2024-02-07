from stilt_utils import sync_csv_files


def test_sync_csv_files_cli(cli_runner):
    def iserr(args, err):
        r = cli_runner.invoke(sync_csv_files.cli, args)
        assert r.exit_code != 0
        assert r.output.strip().endswith(err), r.output.strip()

    iserr([],
          "")

    iserr(["src", "dst"],
          "'src' does not exist.")

    iserr(["/tmp", "dst"],
          "'dst' does not exist.")

    iserr(["/tmp", "/tmp"],
          'Must specify one of --rename or --overwrite')

    iserr(["--overwrite", "--rename", "foo", "/tmp", "/tmp"],
          "Use either --rename or --overwrite")
