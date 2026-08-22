#!/usr/bin/env python3
"""Apply radio settings and create/set the FPV Sim model on an EdgeTX SD card.

Usage: configure.py <settings.env> <sd_root>
"""
import glob
import os
import re
import sys


def load_settings(path):
    s = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            s[k.strip()] = v.strip()
    return s


def apply_settings(radio_path, settings):
    with open(radio_path) as f:
        text = f.read()
    for k, v in settings.items():
        pat = re.compile(r"^([ \t]*)%s:[ \t]*.*$" % re.escape(k), re.M)
        text, n = pat.subn(r"\g<1>%s: %s" % (k, v), text, count=1)
        if n == 0:
            print("WARN: key %r not found in radio.yml (skipped)" % k, file=sys.stderr)
    text = re.sub(
        r"^([ \t]*)manuallyEdited:[ \t]*\d+$",
        r"\g<1>manuallyEdited: 1",
        text, count=1, flags=re.M,
    )
    with open(radio_path, "w") as f:
        f.write(text)


def model_indices(models_dir):
    idxs = []
    for m in glob.glob(os.path.join(models_dir, "model*.yml")):
        mm = re.match(r"model(\d+)\.yml", os.path.basename(m))
        if mm:
            idxs.append(int(mm.group(1)))
    return idxs


def find_model_by_name(models_dir, name):
    for m in glob.glob(os.path.join(models_dir, "model*.yml")):
        with open(m) as f:
            head = f.read(512)
        if re.search(r'name:\s*"%s"' % re.escape(name), head):
            return m
    return None


def find_pocket_model(models_dir):
    return find_model_by_name(models_dir, "POCKET")


def next_index(models_dir):
    idxs = model_indices(models_dir)
    return max(idxs) + 1 if idxs else 0


def remove_mod_block(text):
    """Remove the 'mod:' sub-block (and its indented children) that follows a
    moduleData type line."""
    lines = text.split("\n")
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r"^(\s*)mod:\s*$", line)
        if m:
            indent = len(m.group(1))
            i += 1
            while i < len(lines):
                m2 = re.match(r"^(\s*)\S", lines[i])
                if m2 and len(m2.group(1)) > indent:
                    i += 1
                    continue
                break
            continue
        out.append(line)
        i += 1
    return "\n".join(out)


def create_fpv_model(models_dir, src):
    idx = next_index(models_dir)
    dst = os.path.join(models_dir, "model%02d.yml" % idx)
    with open(src) as f:
        text = f.read()
    text = text.replace('name: "POCKET"', 'name: "FPV Sim"', 1)
    text = text.replace("type: TYPE_CROSSFIRE", "type: TYPE_NONE", 1)
    text = remove_mod_block(text)
    with open(dst, "w") as f:
        f.write(text)
    return idx, dst


def set_curr_model(radio_path, idx):
    with open(radio_path) as f:
        text = f.read()
    text = re.sub(
        r"^([ \t]*)currModel:[ \t]*\d+$",
        r"\g<1>currModel: %d" % idx,
        text, count=1, flags=re.M,
    )
    with open(radio_path, "w") as f:
        f.write(text)


def main():
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    settings_path, sd = sys.argv[1], sys.argv[2].rstrip("/")
    radio_path = os.path.join(sd, "RADIO", "radio.yml")
    models_dir = os.path.join(sd, "MODELS")
    if not os.path.isfile(radio_path):
        print("ERROR: %s not found" % radio_path, file=sys.stderr)
        return 1

    apply_settings(radio_path, load_settings(settings_path))

    fpv = find_model_by_name(models_dir, "FPV Sim")
    if fpv:
        mm = re.match(r"model(\d+)\.yml", os.path.basename(fpv))
        idx = int(mm.group(1)) if mm else next_index(models_dir)
        print("FPV Sim model already exists: %s (index %d)" % (os.path.basename(fpv), idx))
    else:
        src = find_pocket_model(models_dir)
        if not src:
            print("ERROR: no POCKET model found to copy from", file=sys.stderr)
            return 1
        idx, dst = create_fpv_model(models_dir, src)
        print("Created FPV Sim model: %s (index %d)" % (os.path.basename(dst), idx))

    set_curr_model(radio_path, idx)
    print("Default model set to FPV Sim (currModel %d)" % idx)
    return 0


if __name__ == "__main__":
    sys.exit(main())
