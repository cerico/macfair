import json
import plistlib
import subprocess
import sys

path = sys.argv[1] if len(sys.argv) > 1 else "/tmp/app-bindings.json"

with open(path) as f:
    bindings = json.load(f)

out = subprocess.run(["defaults", "export", "com.apple.spaces", "-"], capture_output=True)
if out.returncode == 0:
    plist = plistlib.loads(out.stdout)
    current = plist.get("app-bindings", {})
    if current == bindings:
        print("unchanged")
        sys.exit(0)

cmd = ["defaults", "write", "com.apple.spaces", "app-bindings", "-dict"]
for bundle_id, uuid in bindings.items():
    cmd.extend([bundle_id, "-string", uuid])

subprocess.run(cmd, check=True)
print("changed")
