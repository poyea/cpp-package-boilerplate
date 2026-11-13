#!/usr/bin/env bash
# Usage:
#   package.sh TARGET [CMAKE_ARGS...]
#
# Builds a release and writes
# build/package/cpp-package-boilerplate-TARGET.tar.gz (.zip on Windows).
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "usage: package.sh TARGET [CMAKE_ARGS...]" >&2
    exit 1
fi

target="$1"
shift

build_dir="build/package"

cmake -S . -B "$build_dir" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCPP_PACKAGE_BOILERPLATE_BUILD_TESTS=OFF \
    -DCPP_PACKAGE_BOILERPLATE_BUILD_BENCHMARKS=OFF \
    -DCPP_PACKAGE_BOILERPLATE_BUILD_DOCS=OFF \
    -DCPP_PACKAGE_BOILERPLATE_ENABLE_IPO=OFF \
    -DCPP_PACKAGE_BOILERPLATE_STATIC_RUNTIME=ON \
    -DCPP_PACKAGE_BOILERPLATE_PACKAGE_TARGET="$target" \
    "$@"

cmake --build "$build_dir" --parallel --target package
