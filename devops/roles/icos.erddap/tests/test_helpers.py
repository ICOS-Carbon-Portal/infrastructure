"""Run with python3 -m unittest discover -s devops/roles/icos.erddap/tests."""
import copy
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

FILES = Path(__file__).resolve().parents[1] / "files"


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, FILES / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


requirements = load("requirements", "locked-requirements.py")
setup = load("setup", "validate-setup.py")


class LockedRequirementsTests(unittest.TestCase):
    def setUp(self):
        self.lock = {
            "_meta": {"sources": [{"url": "https://pypi.org/simple"}]},
            "default": {
                "example": {
                    "version": "==1.2.3",
                    "hashes": ["sha256:" + "a" * 64],
                    "markers": "python_version >= '3.9'",
                }
            },
        }

    def test_preserves_version_markers_and_hashes(self):
        text = requirements.render(self.lock)
        self.assertIn("example==1.2.3; python_version >= '3.9' --hash=sha256:", text)
        self.assertIn("a" * 64, text)

    def test_rejects_unpinned_unhashed_and_non_pypi_dependencies(self):
        for patch in [{"version": ">=1.0"}, {"hashes": []}, {"git": "https://example.org/repo"}]:
            lock = copy.deepcopy(self.lock)
            lock["default"]["example"].update(patch)
            with self.assertRaises(ValueError):
                requirements.render(lock)

    def test_rejects_unreviewed_index(self):
        self.lock["_meta"]["sources"][0]["url"] = "https://example.org/simple"
        with self.assertRaises(ValueError):
            requirements.render(self.lock)

    def test_cli_is_idempotent(self):
        import json
        import sys
        with tempfile.TemporaryDirectory() as d:
            source, target = Path(d) / "lock.json", Path(d) / "requirements.txt"
            source.write_text(json.dumps(self.lock))
            args = [sys.executable, str(FILES / "locked-requirements.py"), str(source), str(target)]
            self.assertEqual(subprocess.check_output(args, text=True).strip(), "updated")
            self.assertEqual(subprocess.check_output(args, text=True), "")


class SetupValidationTests(unittest.TestCase):
    def validate(self, text):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "setup.xml"
            path.write_text(text)
            setup.validate(path, "/home/ubuntu/erddap.icos-cp.eu/bigParent")

    def test_valid_config_and_commented_examples(self):
        self.validate("""<setup>
          <!-- <baseUrl>http://example.org</baseUrl> -->
          <bigParentDirectory>/home/ubuntu/erddap.icos-cp.eu/bigParent/</bigParentDirectory>
          <baseUrl>http://localhost:18080</baseUrl>
          <baseHttpsUrl>https://test-erddap.icos-cp.eu</baseHttpsUrl>
        </setup>""")

    def test_missing_fields(self):
        with self.assertRaises(ValueError):
            self.validate("<setup/>")

    def test_wrong_state_directory(self):
        with self.assertRaises(ValueError):
            self.validate("""<setup><bigParentDirectory>/tmp/wrong</bigParentDirectory>
              <baseUrl>http://localhost</baseUrl><baseHttpsUrl>https://localhost</baseHttpsUrl>
            </setup>""")

    def test_invalid_config_does_not_expose_secrets_in_cli_errors(self):
        import sys
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "setup.xml"
            path.write_text("<setup>TOP-SECRET<invalid")
            result = subprocess.run(
                [sys.executable, str(FILES / "validate-setup.py"), str(path), "/tmp/state"],
                capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn("TOP-SECRET", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
