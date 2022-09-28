#!/usr/bin/env bash

set -e
# Download and install sccache in the Windows specific cargo directories
mkdir -p /Users/runner/.cargo/bin
curl -o- -sSLf https://github.com/mozilla/sccache/releases/download/v0.2.15/sccache-v0.2.15-x86_64-pc-windows-msvc.tar.gz | tar --strip-components=1 -C /Users/runner/.cargo/bin -xzf -
chmod 755 /Users/runner/.cargo/bin/sccache
