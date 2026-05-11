#!/usr/bin/env python3

import re
import subprocess
import sys
from os.path import expanduser

config_path = expanduser("~/.config/niri/config.kdl")

with open(config_path, "r") as f:
    content = f.read()

active = re.search(r"^(\s*)tap$", content, re.MULTILINE)
commented = re.search(r"^(\s*)//\s+tap$", content, re.MULTILINE)

if active:
    spaces = active.group(1)
    new_content = re.sub(
        rf"^{re.escape(spaces)}tap$", f"{spaces}// tap", content, flags=re.MULTILINE
    )
    status = "OFF"
elif commented:
    spaces = commented.group(1)
    new_content = re.sub(
        rf"^{re.escape(spaces)}//\s+tap$", f"{spaces}tap", content, flags=re.MULTILINE
    )
    status = "ON"
else:
    print("tap not found in config")
    sys.exit(1)

with open(config_path, "w") as f:
    f.write(new_content)

subprocess.run(["niri", "msg", "action", "load-config-file"])
subprocess.run(["notify-send", "Touchpad", f"Tap-to-click: {status}"])
