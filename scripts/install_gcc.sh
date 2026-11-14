#!/usr/bin/env bash
# Installs GCC 16.1 on Ubuntu from Debian sid.
#
# ubuntu-toolchain-r/test only carries pre-release 16.0.x snapshots, which fail
# the 16.1 floor in CMakeLists.txt. Debian is pinned to priority 100 overall
# and 990 for the GCC 16 packages alone, so nothing else is pulled from sid.
set -euo pipefail

as_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

gcc_packages="gcc-16 gcc-16-* g++-16 g++-16-* cpp-16 cpp-16-* gcc-16-base libgcc-16-dev libstdc++-16-dev libstdc++6 libgcc-s1 libgomp1 libitm1 libatomic1 libquadmath0 libcc1-0 libasan8 libubsan1 liblsan0 libtsan2 libhwasan0"

as_root apt-get update
as_root apt-get install -y --no-install-recommends debian-archive-keyring

echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian sid main" \
    | as_root tee /etc/apt/sources.list.d/debian-sid.list >/dev/null

printf 'Package: *\nPin: release o=Debian\nPin-Priority: 100\n\nPackage: %s\nPin: release o=Debian\nPin-Priority: 990\n' "$gcc_packages" \
    | as_root tee /etc/apt/preferences.d/debian >/dev/null

as_root apt-get update
as_root apt-get install -y --no-install-recommends gcc-16 g++-16

g++-16 --version
