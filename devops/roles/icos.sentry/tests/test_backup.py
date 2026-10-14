"""Backup orchestration tests; requires PyYAML and Jinja2 (Ansible's Python)."""
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
import unittest

import jinja2
import yaml


class BackupTest(unittest.TestCase):
    def run_backup(self, failure=""):
        role = Path(__file__).resolve().parents[1]
        tasks = yaml.safe_load((role / "tasks/backup.yml").read_text())
        values = yaml.safe_load((role / "defaults/main.yml").read_text())
        env = jinja2.Environment(undefined=jinja2.StrictUndefined,
                                 trim_blocks=True, lstrip_blocks=True)
        env.filters.update(quote=shlex.quote, regex_escape=re.escape)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "scripts").mkdir()
            commands = {
                "scripts/backup.sh": 'echo export >> "$LOG"\ntest "$REPORT_SELF_HOSTED_ISSUES" = 0\ntest "$1" = --minimize-downtime\ntest "$FAIL" != export',
                "docker": '''echo "docker $*" >> "$LOG"
case "$*" in
  "volume ls"*) echo sentry-data ;;
  "volume inspect"*) test "$FAIL" != discovery || exit 1; echo /mock/volume ;;
  "compose stop"*) test "$FAIL" != stop ;;
  "compose up"*) test "$FAIL" != restart ;;
esac''',
                "borg-all": 'echo "borg $1" >> "$LOG"\ntest "$FAIL" != "$1"',
            }
            for name, body in commands.items():
                path = root / name
                path.write_text("#!/bin/bash\nset -e\n" + body + "\n")
                path.chmod(0o755)
            values.update(sentry_home=str(root), bbclient_all=str(root / "borg-all"))
            script = env.from_string(tasks[1]["vars"]["bbclient_timer_content"]).render(**values)
            result = subprocess.run(["bash"], input=script, text=True, capture_output=True,
                                    env={**os.environ, "PATH": str(root) + ":" + os.environ["PATH"],
                                         "LOG": str(root / "log"), "FAIL": failure})
            return result.returncode, (root / "log").read_text()

    def test_success_restarts_before_prune(self):
        rc, log = self.run_backup()
        self.assertEqual(rc, 0)
        self.assertLess(log.index("borg create"), log.index("docker compose up"))
        self.assertLess(log.index("docker compose up"), log.index("borg prune"))

    def test_export_failure_does_not_block_backup(self):
        rc, log = self.run_backup("export")
        self.assertEqual(rc, 0)
        self.assertIn("borg create", log)

    def test_discovery_failure_does_not_stop_sentry(self):
        rc, log = self.run_backup("discovery")
        self.assertNotEqual(rc, 0)
        self.assertNotIn("docker compose stop", log)
        self.assertNotIn("borg create", log)

    def test_failure_recovers_and_preserves_failure(self):
        for failure in ("stop", "create", "restart"):
            with self.subTest(failure=failure):
                rc, log = self.run_backup(failure)
                self.assertNotEqual(rc, 0)
                self.assertIn("docker compose up", log)
                self.assertNotIn("borg prune", log)


if __name__ == "__main__":
    unittest.main()
