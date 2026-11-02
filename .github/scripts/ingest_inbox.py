#!/usr/bin/env python3
import json
import os
import pathlib
import subprocess
import sys
import urllib.request

TOPIC = os.environ.get("NOTE_INBOX_TOPIC") or "greetingcard-notes-shamsulamar"
url = f"https://ntfy.sh/{TOPIC}/json?poll=1&since=2h"
script = pathlib.Path(__file__).with_name("append_note.py")

try:
    with urllib.request.urlopen(url, timeout=30) as response:
        raw = response.read().decode("utf-8", errors="replace")
except Exception as error:
    print(f"Could not read inbox: {error}", file=sys.stderr)
    sys.exit(1)

count = 0
for line in raw.splitlines():
    line = line.strip()
    if not line:
        continue
    try:
        event = json.loads(line)
    except json.JSONDecodeError:
        continue
    if event.get("event") != "message":
        continue
    message = event.get("message") or ""
    try:
        payload = json.loads(message)
    except json.JSONDecodeError:
        continue
    if not isinstance(payload, dict):
        continue
    text = str(payload.get("t") or "").strip()
    day = str(payload.get("d") or "").strip()
    if not text or not day:
        continue
    env = os.environ.copy()
    env["NOTE_TEXT"] = text
    env["NOTE_DAY"] = day
    subprocess.check_call(["python3", str(script)], env=env)
    count += 1

print(f"Ingested {count} inbox messages")
