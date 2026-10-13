#!/usr/bin/python3
"""Convert the ingestion project's PyPI-only Pipfile.lock without re-resolving."""
import json
from pathlib import Path
import re
import sys


def render(lock):
    lines = ["# Generated from Pipfile.lock; do not edit."]
    sources = lock["_meta"]["sources"]
    if len(sources) != 1 or sources[0]["url"] != "https://pypi.org/simple":
        raise ValueError("Only the reviewed PyPI source is supported")
    for name, package in sorted(lock["default"].items()):
        version = package.get("version", "")
        hashes = package.get("hashes", [])
        if not re.fullmatch(r"[A-Za-z0-9_.-]+", name):
            raise ValueError("Invalid package name")
        if not re.fullmatch(r"==[A-Za-z0-9_.+!-]+", version) or not hashes:
            raise ValueError(f"{name} must have an exact version and hashes")
        if any(not re.fullmatch(r"sha256:[a-f0-9]{64}", h) for h in hashes):
            raise ValueError(f"Invalid hash for {name}")
        if set(package) - {"version", "hashes", "markers", "index"}:
            raise ValueError(f"Unsupported lock entry for {name}")
        line = name + version
        if package.get("markers"):
            line += "; " + package["markers"]
        lines.append(line + " " + " ".join("--hash=" + h for h in hashes))
    return "\n".join(lines) + "\n"


def main():
    content = render(json.loads(Path(sys.argv[1]).read_text()))
    target = Path(sys.argv[2])
    if not target.exists() or target.read_text() != content:
        target.write_text(content)
        print("updated")


if __name__ == "__main__":
    main()
