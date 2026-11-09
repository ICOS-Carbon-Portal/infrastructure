"""Run in the Python environment containing Ansible (Jinja2 is required)."""
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET

try:
    from jinja2 import Environment, StrictUndefined, UndefinedError
except ImportError:
    Environment = None

TEMPLATE = Path(__file__).resolve().parents[1] / "templates/setup.xml.j2"


@unittest.skipIf(Environment is None, "Run with Ansible's Python/Jinja2 to test templates")
class SetupTemplateTests(unittest.TestCase):
    def render(self, **overrides):
        values = {
            "erddap_setup": {
                "bigParentDirectory": "/home/ubuntu/erddap.icos-cp.eu/bigParent/",
                "baseUrl": "https://test-erddap.icos-cp.eu",
                "baseHttpsUrl": "https://test-erddap.icos-cp.eu",
                "adminInstitution": 'Example & Co <Research> "Unit"',
                "quickRestart": True,
                "listPrivateDatasets": False,
            },
            "erddap_email_username": "user&example",
            "erddap_email_password": 'p&<s>"\'word',
            "erddap_flag_key": "test-only-key",
        }
        values.update(overrides)
        env = Environment(undefined=StrictUndefined)
        return env.from_string(TEMPLATE.read_text()).render(values)

    def test_values_roundtrip_through_xml(self):
        root = ET.fromstring(self.render())
        self.assertEqual(root.tag, "erddapSetup")
        self.assertEqual(root.findtext("emailPassword"), 'p&<s>"\'word')
        self.assertEqual(root.findtext("adminInstitution"), 'Example & Co <Research> "Unit"')
        self.assertEqual(root.findtext("emailUserName"), "user&example")
        self.assertEqual(root.findtext("quickRestart"), "true")
        self.assertEqual(root.findtext("listPrivateDatasets"), "false")
        for tag in ("googleClientID", "orcidClientID", "orcidClientSecret"):
            self.assertEqual(root.findtext(tag), "")

    def test_secret_cannot_inject_xml_elements(self):
        secret = "</emailPassword><flagKeyKey>injected</flagKeyKey>"
        root = ET.fromstring(self.render(erddap_email_password=secret))
        self.assertEqual(root.findtext("emailPassword"), secret)
        self.assertEqual(len(root.findall("flagKeyKey")), 1)
        self.assertEqual(root.findtext("flagKeyKey"), "test-only-key")

    def test_required_secret_is_not_silently_defaulted(self):
        env = Environment(undefined=StrictUndefined)
        with self.assertRaises(UndefinedError):
            env.from_string(TEMPLATE.read_text()).render(erddap_setup={})


if __name__ == "__main__":
    unittest.main()
