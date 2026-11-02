#!/usr/bin/env python3
import json
import os
import pathlib
import re
import sys

MAX_NOTE_LENGTH = 160
MAX_NOTES_PER_DAY = 80

text = (os.environ.get("NOTE_TEXT") or "").strip()
day = (os.environ.get("NOTE_DAY") or "").strip()
path = pathlib.Path(os.environ.get("NOTES_PATH") or "notes.json")

if not text:
    print("Empty note; skipping", file=sys.stderr)
    sys.exit(0)
if len(text) > MAX_NOTE_LENGTH:
    text = text[:MAX_NOTE_LENGTH].rstrip() + "…"
if re.search(r"https?://", text, re.I):
    print("Rejected note that looks like a link", file=sys.stderr)
    sys.exit(0)
if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", day):
    print(f"Invalid day {day!r}", file=sys.stderr)
    sys.exit(1)

if path.exists():
    data = json.loads(path.read_text(encoding="utf-8"))
else:
    data = {"notes": []}

notes = data.get("notes")
if not isinstance(notes, list):
    notes = []

normalized = []
for item in notes:
    if not isinstance(item, dict):
        continue
    item_text = str(item.get("t") or "").strip()
    item_day = str(item.get("d") or "").strip()
    if item_text:
        normalized.append({"t": item_text, "d": item_day})

if any(item["t"] == text and item["d"] == day for item in normalized):
    print("Note already present")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({"notes": normalized}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    sys.exit(0)

normalized.append({"t": text, "d": day})
same_day_indexes = [i for i, item in enumerate(normalized) if item["d"] == day]
if len(same_day_indexes) > MAX_NOTES_PER_DAY:
    drop = set(same_day_indexes[:-MAX_NOTES_PER_DAY])
    normalized = [item for i, item in enumerate(normalized) if i not in drop]

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps({"notes": normalized}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {len(normalized)} notes to {path}")
