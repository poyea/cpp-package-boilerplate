#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    echo "this script currently supports apt-based environments only" >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y \
    build-essential \
    clang \
    clang-format \
    clang-tidy \
    cmake \
    doxygen \
    gdb \
    git-lfs \
    graphviz \
    ninja-build \
    valgrind

if [[ -z "${VCPKG_ROOT:-}" ]]; then
    export VCPKG_ROOT="${HOME}/.local/vcpkg"
fi

if [[ ! -d "${VCPKG_ROOT}" ]]; then
    git clone https://github.com/microsoft/vcpkg.git "${VCPKG_ROOT}"
fi

"${VCPKG_ROOT}/bootstrap-vcpkg.sh" -disableMetrics
