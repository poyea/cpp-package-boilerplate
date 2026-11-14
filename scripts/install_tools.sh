#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt >/dev/null 2>&1; then
    echo "this script currently supports apt-based environments only" >&2
    exit 1
fi

echo "removing and install latest cmake..."
sudo apt remove -y cmake || true
pip install cmake --upgrade

sudo apt install -y \
    build-essential \
    clang \
    clang-format \
    clang-tidy \
    doxygen \
    gdb \
    git-lfs \
    graphviz \
    ninja-build \
    valgrind

if command -v g++-16 >/dev/null 2>&1; then
    echo "g++-16 already present: $(g++-16 --version | head -n1)"
else
    echo
    echo "this project requires GCC 16.1, which no Ubuntu release packages yet."
    echo "the only source is Debian sid. this adds a sid apt source to your"
    echo "system, pinned to priority 100 so nothing is pulled from it except the"
    echo "gcc-16 packages listed below at priority 990."
    echo
    read -r -p "add the pinned Debian sid source? [y/N] " reply
    if [[ "${reply}" == "y" || "${reply}" == "Y" ]]; then
        bash "$(dirname "${BASH_SOURCE[0]}")/install_gcc.sh"
    else
        echo "skipped. install GCC 16.1 yourself, or cmake configure will fail" >&2
        echo "the version gate in CMakeLists.txt." >&2
    fi
fi

if [[ -z "${VCPKG_ROOT:-}" ]]; then
    export VCPKG_ROOT="${HOME}/.local/vcpkg"
fi

if [[ ! -d "${VCPKG_ROOT}" ]]; then
    git clone https://github.com/microsoft/vcpkg.git "${VCPKG_ROOT}"
fi

"${VCPKG_ROOT}/bootstrap-vcpkg.sh" -disableMetrics
