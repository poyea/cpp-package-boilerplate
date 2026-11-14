# cpp-package-boilerplate [![ci](https://github.com/poyea/cpp-package-boilerplate/actions/workflows/ci.yml/badge.svg)](https://github.com/poyea/cpp-package-boilerplate/actions/workflows/ci.yml) [![release](https://img.shields.io/github/v/release/poyea/cpp-package-boilerplate)](https://github.com/poyea/cpp-package-boilerplate/releases/latest) [![downloads](https://img.shields.io/github/downloads/poyea/cpp-package-boilerplate/total)](https://github.com/poyea/cpp-package-boilerplate/releases)

Modern C++ package boilerplate with CMake, tests, benchmarks, docs, devcontainers, Docker, and GitHub Actions.

## What this template supports

- C++26 by default, with compiler checks for recent toolchains.
- Compiled library, header-only library, CLI, or mixed library plus CLI layouts.
- GoogleTest-based unit tests and Google Benchmark integration.
- Doxygen documentation generation.
- Dev container and Codespaces setup with a repository-owned toolchain.
- Docker build support for a runnable runtime image.
- Install rules, a `find_package()` config and CPack archives.
- Tag-driven releases with per-platform archives, checksums and an install script.
- Clang-format, strict warnings, sanitizers, and release LTO.

## Using this template

After creating a repository from this template:

1. Rename the project: replace `cpp_package_boilerplate`, `cpp-package-boilerplate` and `CPP_PACKAGE_BOILERPLATE` throughout, including the `include/cpp_package_boilerplate/` directory.
2. Point the links at your repository: the badges and URLs in this README, and `repo` in `scripts/install.sh`.
3. Set the starting `version` in `vcpkg.json`.
4. In the repository settings, set Pages to deploy from GitHub Actions.
5. Set the repository homepage to the Pages URL, so the documentation is one click from the repository page.
6. Enable Discussions if you want a support channel that is separate from the issue tracker.
7. Create the `breaking` label, which the generated release notes use alongside the default `enhancement`, `bug` and `documentation` labels.
8. Set the repository variable `PUBLISH_DOCKER_IMAGE` to `true` if releases should push an image to GitHub Container Registry.

## Prerequisites

**Required:**

| Tool | Minimum version | Purpose |
|---|---|---|
| CMake | 4.3 | Build system |
| GCC | 16.1 | C++ compiler (Linux/Windows) |
| Clang | 18 | C++ compiler (alternative) |
| AppleClang | 16 | C++ compiler (macOS) |
| MSVC | 19.40 (VS 2022 17.10) | C++ compiler (Windows) |
| Ninja | 1.11 | Build tool |
| Git | 2 | Source control |

**Feature-specific tools:**

| Tool | Purpose |
|---|---|
| clang-format | Code formatting (`scripts/format.sh`) |
| clang-tidy | Static analysis (`tidy` preset) |
| vcpkg | C/C++ dependency management for tests and benchmarks |
| Doxygen + Graphviz | API documentation (`BUILD_DOCS=ON`) |
| Valgrind | Profiling (`profile` preset) |
| perf | Profiling (`profile` preset, Linux only) |
| Docker | Runtime container image |

**Install on Ubuntu/Debian:**

```bash
bash scripts/install_tools.sh
```

After installation, export `VCPKG_ROOT` if needed:

```bash
export VCPKG_ROOT="${HOME}/.local/vcpkg"
```

**Dev container / Codespaces:** all tools are pre-installed, no manual setup needed.

## Quick start

```bash
cmake --workflow --preset debug
```

A workflow preset configures, builds and tests in one command.
The steps are also available one at a time:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

| Preset | Build type | What it does |
|---|---|---|
| `debug` | Debug | Builds and tests with AddressSanitizer and UBSan |
| `release` | Release | Builds and tests with LTO |
| `ci` | RelWithDebInfo | Builds and tests without sanitizers |
| `benchmarks` | Release | Builds the benchmarks |
| `profile` | RelWithDebInfo | Builds the benchmarks with debug information |
| `tidy` | Debug | Builds with clang-tidy on every translation unit |
| `docs` | Debug | Generates the Doxygen documentation |

Every preset except `docs` has a `-vcpkg` variant, such as `debug-vcpkg`, which takes dependencies from the vcpkg manifest and needs `VCPKG_ROOT`.
Without it, GoogleTest and Google Benchmark are downloaded at configure time.
Each preset builds into `build/<preset>`.

## Installing a release

Each [release](https://github.com/poyea/cpp-package-boilerplate/releases) ships a prebuilt archive per platform, containing the CLI, the static library, its headers and a CMake package config.

| Target | Archive |
|---|---|
| Linux x86_64 | `cpp-package-boilerplate-x86_64-unknown-linux-gnu.tar.gz` |
| Linux arm64 | `cpp-package-boilerplate-aarch64-unknown-linux-gnu.tar.gz` |
| macOS x86_64 | `cpp-package-boilerplate-x86_64-apple-darwin.tar.gz` |
| macOS arm64 | `cpp-package-boilerplate-aarch64-apple-darwin.tar.gz` |
| Windows x86_64 | `cpp-package-boilerplate-x86_64-pc-windows-msvc.zip` |
| Windows arm64 | `cpp-package-boilerplate-aarch64-pc-windows-msvc.zip` |

The Linux CLI is fully statically linked, so it runs on any distribution.

### Install script

The install script downloads the archive for the current platform, verifies its checksum and copies the CLI into a directory of your choice:

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/poyea/cpp-package-boilerplate/main/scripts/install.sh | bash -s -- --to ~/.local/bin
```

Pass `--tag v1.2.3` to install a specific release instead of the latest one, and `--force` to overwrite an existing binary.
On Windows, run it from Git Bash.

### Verifying a download

Every release includes a `SHA256SUMS` file.
To verify archives downloaded by hand, place it next to them and run:

```bash
sha256sum --ignore-missing --check SHA256SUMS
```

Every archive also carries a signed build provenance attestation.
It proves that the release workflow of this repository built the file:

```bash
gh attestation verify cpp-package-boilerplate-x86_64-unknown-linux-gnu.tar.gz --repo poyea/cpp-package-boilerplate
```

### Using the library from CMake

Extract an archive, or run `cmake --install build/release --prefix <prefix>` on your own build, then point CMake at that prefix:

```cmake
find_package(cpp_package_boilerplate 0.2 REQUIRED)
target_link_libraries(my_app PRIVATE cpp_package_boilerplate::cpp_package_boilerplate)
```

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=<prefix>
```

The Windows library is built against the DLL CRT (`/MD`), which is the CMake default, so it links into an ordinary project.

### Release feed

GitHub publishes an [Atom feed of releases](https://github.com/poyea/cpp-package-boilerplate/releases.atom).
Subscribe to it in any feed reader to be notified of new versions.

## Project options

Key CMake options:

- `CPP_PACKAGE_BOILERPLATE_BUILD_LIBRARY=ON|OFF`
- `CPP_PACKAGE_BOILERPLATE_BUILD_CLI=ON|OFF`
- `CPP_PACKAGE_BOILERPLATE_HEADER_ONLY=ON|OFF`
- `CPP_PACKAGE_BOILERPLATE_BUILD_TESTS=ON|OFF`
- `CPP_PACKAGE_BOILERPLATE_BUILD_BENCHMARKS=ON|OFF`
- `CPP_PACKAGE_BOILERPLATE_BUILD_DOCS=ON|OFF`
- `CPP_PACKAGE_BOILERPLATE_STATIC_RUNTIME=ON|OFF`

`CPP_PACKAGE_BOILERPLATE_STATIC_RUNTIME` is meant for distribution builds.
It links the CLI fully statically on Linux and against the static CRT (`/MT`) with MSVC, and has no effect on macOS.
The library itself is not affected.
A fully static glibc binary cannot load NSS modules or `dlopen` shared objects, so leave it off if the CLI needs either.

Examples:

```bash
cmake -S . -B build/header-only -G Ninja -DCPP_PACKAGE_BOILERPLATE_HEADER_ONLY=ON
cmake -S . -B build/library-only -G Ninja -DCPP_PACKAGE_BOILERPLATE_BUILD_CLI=OFF
cmake -S . -B build/full -G Ninja -DCPP_PACKAGE_BOILERPLATE_BUILD_BENCHMARKS=ON -DCPP_PACKAGE_BOILERPLATE_BUILD_DOCS=ON
```

## Repository layout

- `cmake/`: shared compiler and toolchain settings
- `include/`: public headers
- `src/`: compiled library and CLI sources
- `tests/`: unit tests
- `benchmarks/`: performance benchmarks
- `docs/`: Doxygen configuration
- `.devcontainer/`: development container for VS Code and Codespaces
- `.github/workflows/`: CI, docs, Docker, and release automation
- `scripts/`: local developer helpers

## Formatting

```bash
bash scripts/format.sh
bash scripts/format.sh --check
cmake --build --preset debug --target format
cmake --build --preset debug --target format-check
```

## Static analysis

```bash
cmake --workflow --preset tidy
```

## Benchmarks and profiling

```bash
cmake --workflow --preset benchmarks
build/benchmarks/benchmarks/cpp_package_boilerplate_benchmarks
build/benchmarks/benchmarks/cpp_package_boilerplate_benchmarks --benchmark_filter=BM_Add
```

To profile, build the benchmarks with debug information and run them under a profiler:

```bash
cmake --workflow --preset profile
perf record --call-graph dwarf build/profile/benchmarks/cpp_package_boilerplate_benchmarks
valgrind --tool=callgrind build/profile/benchmarks/cpp_package_boilerplate_benchmarks
```

## Packaging

```bash
bash scripts/package.sh x86_64-unknown-linux-gnu
```

This builds a release with a static runtime and writes the archive to `build/package/`.
The release workflow runs the same script for every target.

## Documentation

```bash
cmake --workflow --preset docs
```

The site is written to `build/docs/docs/site/html`.

The docs workflow builds the documentation on every pull request and on every push to the default branch, so a broken build is caught before it merges.
It publishes to GitHub Pages only when a stable release is tagged, so the site always describes the latest release while this README describes the default branch.

To publish the documentation for a given ref by hand:

```bash
gh workflow run docs.yml --field ref=v0.2.0
```

## Container workflows

- Dev container: open the repository in a compatible devcontainer client or GitHub Codespaces.
- Runtime image: `docker build -t cpp-package-boilerplate:latest .`

## Stability

Releases follow [Semantic Versioning](https://semver.org).
The public API is everything declared in the headers under `include/`, plus the exported CMake target `cpp_package_boilerplate::cpp_package_boilerplate`.

- A patch release only fixes bugs.
- A minor release may add to the public API, but does not remove or change what is already there.
- A major release may break source compatibility, and its release notes list every breaking change under a "Breaking" heading.

While the version is below 1.0, a minor release may also contain breaking changes.

The CMake package config enforces this: `find_package(cpp_package_boilerplate 1.2)` accepts any installed 1.x at or above 1.2, and rejects 2.x.

There is no ABI stability guarantee.
The library is distributed as a static archive, so rebuild and relink against each new version.

The CLI, its flags and its output are covered by the same rules as the API.

## License

MIT
