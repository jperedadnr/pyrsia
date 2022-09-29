#!/usr/bin/env bash

set -e
# Download and install sccache in the Windows specific cargo directories
mkdir -p C:\Users\runneradmin\.cargo\bin
curl -o- -sSLf https://github.com/mozilla/sccache/releases/download/v0.3.0/sccache-v0.3.0-x86_64-pc-windows-msvc.tar.gz | tar --strip-components=1 -C C:\Users\runneradmin\.cargo\bin -xzf -
