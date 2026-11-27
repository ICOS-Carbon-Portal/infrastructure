#!/usr/bin/python3
# Installed by the icos.timer role. Runs as ExecStartPre= and ExecStopPost= of
# timer services that set timer_sentry_monitor, and reports to Sentry Crons.
#
#   icos-sentry-checkin ENV_FILE start SLUG
#   icos-sentry-checkin ENV_FILE finish SLUG
#
# A failed run also sends a Sentry event with the run's journal attached, since
# check-ins can't carry output.

import json
import os
import re
import socket
import subprocess
import sys
import time
import urllib.request
import uuid
from typing import NamedTuple

RETRIES = 3
TIMEOUT_SECONDS = 10
JOURNAL_BYTE_LIMIT = 100000


class SentryConf(NamedTuple):
    envelope_url: str
    public_key: str


def main():
    if len(sys.argv) != 4 or sys.argv[2] not in ("start", "finish"):
        print(f"usage: {sys.argv[0]} ENV_FILE start|finish SLUG", file=sys.stderr)
        sys.exit(2)
    env_file, action, slug = sys.argv[1], sys.argv[2], sys.argv[3]
    sentry_conf = read_env_file(env_file)

    # systemd's INVOCATION_ID is the same for ExecStartPre= and ExecStopPost=
    # of a run and has the format of both a check-in ID and a trace ID, so it
    # pairs the start and finish check-ins and links them to the failure event.
    invocation_id = os.environ.get("INVOCATION_ID", "")
    if re.fullmatch(r"[0-9a-f]{32}", invocation_id):
        run_id = invocation_id
    else:
        invocation_id = ""
        run_id = uuid.uuid4().hex

    if action == "start":
        check_in(sentry_conf, run_id, run_id, slug, "in_progress")
        return

    # SERVICE_RESULT, EXIT_CODE and EXIT_STATUS are set by systemd for
    # ExecStopPost= commands.
    service_result = os.environ.get("SERVICE_RESULT", "unknown")
    if service_result == "success":
        check_in(sentry_conf, run_id, run_id, slug, "ok")
        return

    status_line = " ".join([
        f"result={service_result}",
        f"exit_code={os.environ.get('EXIT_CODE', 'unknown')}",
        f"exit_status={os.environ.get('EXIT_STATUS', 'unknown')}",
    ])
    log = journal(invocation_id, JOURNAL_BYTE_LIMIT)
    failure_event(sentry_conf, run_id, slug, status_line, log)
    check_in(sentry_conf, run_id, run_id, slug, "error")


def read_env_file(path):
    envelope_url = None
    public_key = None
    with open(path) as f:
        for line in f:
            key, _, value = line.rstrip("\n").partition("=")
            if key == "SENTRY_ENVELOPE_URL":
                envelope_url = value
            elif key == "SENTRY_PUBLIC_KEY":
                public_key = value
    if not envelope_url or not public_key:
        raise ValueError(f"{path} must set SENTRY_ENVELOPE_URL and SENTRY_PUBLIC_KEY")
    return SentryConf(envelope_url=envelope_url, public_key=public_key)


def check_in(sentry_conf, check_in_id, trace_id, slug, status):
    payload = {
        "check_in_id": check_in_id,
        "monitor_slug": slug,
        "status": status,
        "contexts": {"trace": {"trace_id": trace_id}},
    }
    body = envelope({}, [({"type": "check_in"}, json.dumps(payload).encode())])
    send(sentry_conf, body, f"{status} check-in of {slug}")


def journal(invocation_id, byte_limit):
    if not invocation_id:
        return b""
    subprocess.run(["journalctl", "--sync"], stderr=subprocess.DEVNULL)
    output = subprocess.run(
        ["journalctl", "--no-pager", "--output=cat", f"_SYSTEMD_INVOCATION_ID={invocation_id}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    ).stdout
    return output[-byte_limit:]


def failure_event(sentry_conf, trace_id, slug, status_line, log):
    event_id = uuid.uuid4().hex
    event = {
        "event_id": event_id,
        "timestamp": time.time(),
        "platform": "other",
        "level": "error",
        "logger": "icos-timer",
        "server_name": socket.gethostname(),
        "logentry": {"formatted": f"{slug} failed: {status_line}"},
        # One issue per timer, however the message varies between runs
        "fingerprint": ["icos-timer", slug],
        "tags": {"timer": slug},
        "contexts": {"trace": {"trace_id": trace_id, "span_id": os.urandom(8).hex()}},
    }
    items = [({"type": "event", "content_type": "application/json"}, json.dumps(event).encode())]
    if log:
        items.append(({
            "type": "attachment",
            "content_type": "text/plain",
            "filename": "journal.txt",
        }, log))
    body = envelope({"event_id": event_id}, items)
    send(sentry_conf, body, f"failure event of {slug}")


def envelope(header, items):
    parts = [json.dumps(header).encode()]
    for item_header, payload in items:
        parts.append(json.dumps({**item_header, "length": len(payload)}).encode())
        parts.append(payload)
    return b"\n".join(parts) + b"\n"


def send(sentry_conf, body, description):
    request = urllib.request.Request(
        sentry_conf.envelope_url,
        data=body,
        headers={
            "Content-Type": "application/x-sentry-envelope",
            "X-Sentry-Auth": f"Sentry sentry_version=7, sentry_key={sentry_conf.public_key}, sentry_client=icos-sentry-checkin/1.0",
        },
    )
    for attempt in range(RETRIES + 1):
        try:
            with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS):
                return
        except Exception as e:
            error = e
            if attempt < RETRIES:
                time.sleep(attempt + 1)
    print(f"warning: could not send {description} to Sentry: {error}", file=sys.stderr)


try:
    main()
except Exception as e:
    print(f"warning: icos-sentry-checkin: {e}", file=sys.stderr)
sys.exit(0)
