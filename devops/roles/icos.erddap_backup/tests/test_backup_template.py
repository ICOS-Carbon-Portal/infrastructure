"""Exercise the rendered shell job with real SQLite and a local fake Borg."""
from contextlib import closing
import os
from pathlib import Path
import shlex
import sqlite3
import subprocess
import tempfile
import unittest

try:
    from jinja2 import Environment, FileSystemLoader, StrictUndefined
except ImportError:
    Environment = None


@unittest.skipIf(Environment is None, "Run with Ansible's Python/Jinja2 to test templates")
class BackupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.home = self.root / 'application'
        self.home.mkdir()
        (self.home / '.ingestion.lock').touch()
        self.state = self.root / 'state'
        self.state.mkdir()
        self.auth = self.home / 'credentials.json'
        self.auth.write_text('{"test": "not-a-real-secret"}')
        self.database = self.home / 'icos-erddap/erddap_transfer/erddap_transfer.sqlite'
        self.database.parent.mkdir(parents=True)
        with closing(sqlite3.connect(self.database)) as db, db:
            db.execute('CREATE TABLE objects (id INTEGER PRIMARY KEY, deleted INTEGER)')
            db.executemany('INSERT INTO objects VALUES (?, ?)', [(1, 0), (2, 1)])
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.command('crontab', '''#!/bin/sh
if [ "${NO_CRONTAB:-0}" = 1 ]; then echo "no crontab for ubuntu" >&2; exit 1; fi
printf "# fixture crontab\\n"
''')
        self.command('borg', '''#!/bin/bash
set -eu
echo "$1" >> "$TRACE"
if [[ "$1" == create ]]; then
    if [[ "${FAIL_CREATE:-0}" == 1 ]]; then exit 2; fi
    mkdir "$RESTORED"
    cp -a rootfs ubuntu.crontab "$RESTORED/"
fi
''')
        env = Environment(
            loader=FileSystemLoader(Path(__file__).resolve().parents[1] / 'templates'),
            undefined=StrictUndefined,
        )
        env.filters['quote'] = shlex.quote
        rendered = env.get_template('backup.sh.j2').render(
            erddap_backup_user='ubuntu',
            erddap_backup_home=str(self.home), erddap_backup_state_dir=str(self.state),
            erddap_backup_required_paths=[str(self.auth)],
            erddap_backup_optional_paths=[str(self.home / 'absent')],
            erddap_backup_keep_daily=14, erddap_backup_keep_weekly=8,
            erddap_backup_keep_monthly=12,
        ).replace('/usr/local/sbin/erddap-borg', str(self.bin / 'borg'))
        self.script = self.root / 'backup.sh'
        self.script.write_text(rendered)
        self.environment = {
            **os.environ, 'PATH': str(self.bin) + ':' + os.environ['PATH'],
            'TRACE': str(self.root / 'trace'), 'RESTORED': str(self.root / 'restored'),
        }

    def command(self, name, content):
        path = self.bin / name
        path.write_text(content)
        path.chmod(0o700)

    def run_backup(self, **extra_environment):
        return subprocess.run(
            ['bash', str(self.script)], env={**self.environment, **extra_environment},
            capture_output=True, text=True,
        )

    def test_snapshot_and_credentials_are_restorable(self):
        result = self.run_backup()
        self.assertEqual(result.returncode, 0, result.stderr)
        rootfs = self.root / 'restored/rootfs'
        self.assertEqual((rootfs / str(self.auth).lstrip('/')).read_bytes(), self.auth.read_bytes())
        with closing(sqlite3.connect(rootfs / str(self.database).lstrip('/'))) as db:
            self.assertEqual(db.execute('PRAGMA integrity_check').fetchone(), ('ok',))
            self.assertEqual(db.execute('SELECT * FROM objects ORDER BY id').fetchall(), [(1, 0), (2, 1)])
        self.assertEqual((self.root / 'trace').read_text().splitlines(), ['create', 'prune', 'compact'])
        self.assertFalse(list(self.state.glob('stage.*')))

    def test_missing_crontab_does_not_abort_backup(self):
        result = self.run_backup(NO_CRONTAB='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / 'trace').read_text().splitlines(), ['create', 'prune', 'compact'])

    def test_failed_create_never_prunes(self):
        self.assertNotEqual(self.run_backup(FAIL_CREATE='1').returncode, 0)
        self.assertEqual((self.root / 'trace').read_text().splitlines(), ['create'])
        self.assertFalse(list(self.state.glob('stage.*')))

    def test_missing_credentials_abort_backup(self):
        self.auth.unlink()
        self.assertNotEqual(self.run_backup().returncode, 0)
        self.assertFalse((self.root / 'trace').exists())
        self.assertFalse(list(self.state.glob('stage.*')))

    def test_missing_database_is_not_silently_created(self):
        self.database.unlink()
        self.assertNotEqual(self.run_backup().returncode, 0)
        self.assertFalse(self.database.exists())
        self.assertFalse((self.root / 'trace').exists())
        self.assertFalse(list(self.state.glob('stage.*')))


if __name__ == '__main__':
    unittest.main()
