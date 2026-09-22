#!/usr/bin/env bash
# Create a dedicated Meteor75 Pro II O4 model from the radio's live ELRS model.
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

SD="$(detect_sd)"
python3 - "$SD/MODELS" <<'PY'
from pathlib import Path
import re
import sys

models = Path(sys.argv[1])
source = models / "model00.yml"
name = "M75P2 O4"
if not source.is_file():
    raise SystemExit("POCKET source model is missing")

for path in sorted(models.glob("model[0-9][0-9].yml")):
    text = path.read_bytes()
    if re.search(rb'^   name: "' + name.encode() + rb'"\r?$', text, re.M):
        print(f"Meteor75 Pro II O4 model already exists: {path.name}")
        raise SystemExit(0)

text = source.read_bytes()
if not re.search(rb'^   name: "POCKET"\r?$', text, re.M):
    raise SystemExit("model00.yml is not the expected POCKET model")
if b"type: TYPE_CROSSFIRE" not in text:
    raise SystemExit("POCKET model does not have its internal ELRS/CRSF module enabled")

text = text.replace(b'name: "POCKET"', b'name: "' + name.encode() + b'"', 1)
text, count = re.subn(rb'(?m)^(      value: )\d+(\r?)$', rb'\g<1>0\2', text, count=1)
if count != 1:
    raise SystemExit("Could not reset the copied model timer")

indices = [int(path.stem[5:]) for path in models.glob("model[0-9][0-9].yml")]
index = max(indices, default=-1) + 1
if index > 99:
    raise SystemExit("No free two-digit model index")
target = models / f"model{index:02d}.yml"
with target.open("xb") as output:
    output.write(text)
print(f"Created {target.name}: {name} (select it on the radio before binding)")
PY
