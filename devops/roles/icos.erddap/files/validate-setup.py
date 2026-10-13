#!/usr/bin/python3
"""Validate setup.xml without printing secret values on errors."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET


def validate(filename, big_parent):
    root = ET.parse(filename).getroot()
    for tag in ("bigParentDirectory", "baseUrl", "baseHttpsUrl"):
        if len(root.findall(tag)) != 1 or not root.findtext(tag, "").strip():
            raise ValueError("Missing or duplicate configuration field")
    if Path(root.findtext("bigParentDirectory").strip()) != Path(big_parent):
        raise ValueError("Unexpected state directory")


if __name__ == "__main__":
    try:
        validate(sys.argv[1], sys.argv[2])
    except Exception:
        sys.exit("Invalid setup.xml: check XML, URLs and bigParentDirectory")
