#!/usr/bin/env bash
set -euo pipefail

repo="poyea/cpp-package-boilerplate"
package="cpp-package-boilerplate"
binary="cpp_package_boilerplate_cli"

usage() {
    cat <<EOF
Install a released ${binary} binary from GitHub.

Usage:
    install.sh [--tag TAG] [--to DIR] [--target TARGET] [--force]

Options:
    --tag TAG        Release tag to install [default: latest release]
    --to DIR         Directory to install into [default: ~/.local/bin]
    --target TARGET  Platform to install [default: detected]
    --force          Overwrite an existing binary
    -h, --help       Show this message
EOF
}

fail() {
    echo "install: error: $*" >&2
    exit 1
}

need() {
    command -v "$1" >/dev/null 2>&1 || fail "need $1 (command not found)"
}

detect_target() {
    local arch os

    case "$(uname -m)" in
        x86_64 | amd64) arch="x86_64" ;;
        arm64 | aarch64) arch="aarch64" ;;
        *) fail "unsupported architecture: $(uname -m)" ;;
    esac

    case "$(uname -s)" in
        Linux) os="unknown-linux-gnu" ;;
        Darwin) os="apple-darwin" ;;
        MINGW* | MSYS* | CYGWIN*) os="pc-windows-msvc" ;;
        *) fail "unsupported operating system: $(uname -s)" ;;
    esac

    echo "${arch}-${os}"
}

download() {
    curl --proto '=https' --tlsv1.2 --silent --show-error --fail --location --output "$2" "$1"
}

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    else
        need shasum
        shasum -a 256 "$1" | cut -d ' ' -f 1
    fi
}

tag=""
to="${HOME}/.local/bin"
target=""
force="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag)
            [[ $# -ge 2 ]] || fail "--tag needs a value"
            tag="$2"
            shift 2
            ;;
        --to)
            [[ $# -ge 2 ]] || fail "--to needs a value"
            to="$2"
            shift 2
            ;;
        --target)
            [[ $# -ge 2 ]] || fail "--target needs a value"
            target="$2"
            shift 2
            ;;
        --force)
            force="true"
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            fail "unknown argument: $1"
            ;;
    esac
done

need curl

if [[ -z "$target" ]]; then
    target="$(detect_target)"
fi

case "$target" in
    *-windows-*)
        need unzip
        archive="${package}-${target}.zip"
        executable="${binary}.exe"
        ;;
    *)
        need tar
        archive="${package}-${target}.tar.gz"
        executable="${binary}"
        ;;
esac

if [[ -z "$tag" ]]; then
    base_url="https://github.com/${repo}/releases/latest/download"
else
    base_url="https://github.com/${repo}/releases/download/${tag}"
fi

destination="${to}/${executable}"

if [[ -e "$destination" && "$force" != "true" ]]; then
    fail "${destination} already exists, pass --force to overwrite it"
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

echo "install: downloading ${archive}" >&2
download "${base_url}/${archive}" "${workdir}/${archive}" || fail "could not download ${base_url}/${archive}"
download "${base_url}/SHA256SUMS" "${workdir}/SHA256SUMS" || fail "could not download ${base_url}/SHA256SUMS"

expected="$(awk -v name="$archive" '$2 == name { print $1 }' "${workdir}/SHA256SUMS")"
actual="$(sha256 "${workdir}/${archive}")"

if [[ -z "$expected" ]]; then
    fail "${archive} is not listed in SHA256SUMS"
fi

if [[ "$expected" != "$actual" ]]; then
    fail "checksum mismatch for ${archive}: expected ${expected}, got ${actual}"
fi

case "$archive" in
    *.zip) unzip -q "${workdir}/${archive}" -d "$workdir" ;;
    *) tar -xzf "${workdir}/${archive}" -C "$workdir" ;;
esac

mkdir -p "$to"
cp "${workdir}/${package}-${target}/bin/${executable}" "$destination"
chmod +x "$destination"

echo "install: installed ${destination}" >&2
