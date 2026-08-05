#!/bin/sh
# Stage mach's self-contained std-only src/mpsc.zig at a pinned commit into
# vendor/ (git-ignored). Single file, no clone.
set -eu
MACH_COMMIT=4be8e50fc89a532878887dba002f590cc50d8e89
DIR=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$DIR/vendor"
if [ -f "$DIR/vendor/mpsc.zig" ]; then echo "already staged"; exit 0; fi
curl -sL "https://raw.githubusercontent.com/hexops/mach/$MACH_COMMIT/src/mpsc.zig" -o "$DIR/vendor/mpsc.zig"
echo "mpsc.zig staged"
