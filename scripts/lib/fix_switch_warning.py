#!/usr/bin/env python3
"""Fix the EdgeTX 2.10 -> 2.12 switch-warning migration bug in model files.

Rewrites the switch warning config of every model to: SA/SB/SC/SD = up
(removing the invalid SE: mid that the migration introduces, and restoring SC).

Usage: fix_switch_warning.py <models_dir>
"""
import glob
import os
import sys

NEW_BLOCK = (
    "switchWarning: \n"
    "   SA:\n"
    "      pos: up\n"
    "   SB:\n"
    "      pos: up\n"
    "   SC:\n"
    "      pos: up\n"
    "   SD:\n"
    "      pos: up\n"
)
NEW_BLOCK_LINES = NEW_BLOCK.rstrip("\n").split("\n")


def fix_text(text):
    lines = text.split("\n")
    out = []
    i = 0
    changed = False
    while i < len(lines):
        line = lines[i]
        if line.startswith("switchWarningState:"):
            i += 1  # old single-line format
            out.extend(NEW_BLOCK_LINES)
            changed = True
        elif line.rstrip() == "switchWarning:":
            i += 1  # new block: skip indented children
            while i < len(lines) and (lines[i] == "" or lines[i].startswith((" ", "\t"))):
                i += 1
            out.extend(NEW_BLOCK_LINES)
            changed = True
        else:
            out.append(line)
            i += 1
    return "\n".join(out), changed


def main():
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    models_dir = sys.argv[1]
    files = sorted(glob.glob(os.path.join(models_dir, "model*.yml")))
    if not files:
        print("No model files found in %s" % models_dir, file=sys.stderr)
        return 1

    for path in files:
        with open(path, "r", newline="") as f:
            raw = f.read()
        crlf = "\r\n" in raw
        text = raw.replace("\r\n", "\n")
        new_text, changed = fix_text(text)
        if changed and new_text != text:
            if crlf:
                new_text = new_text.replace("\n", "\r\n")
            with open(path, "w", newline="") as f:
                f.write(new_text)
            print("fixed: %s" % os.path.basename(path))
        else:
            print("ok:    %s" % os.path.basename(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
