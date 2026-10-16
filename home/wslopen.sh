#!/bin/bash
#!/bin/sh
url=$(printf '%s' "$1" | sed 's/&/^\&/g')
cmd.exe /c start "" "$url" >/dev/null 2>&1
exit 0
