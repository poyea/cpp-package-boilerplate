# Contributing

## Local workflow

1. Configure with `cmake --preset debug`.
2. Build with `cmake --build --preset debug`.
3. Run tests with `ctest --preset debug`.
4. Format with `bash scripts/format.sh`.
5. Run static analysis with `bash scripts/tidy.sh`.
6. For dependency-manager validation use `cmake --preset debug-vcpkg` then `cmake --build --preset debug-vcpkg`.
7. Run benchmarks with `bash scripts/build.sh --benchmark` when performance-sensitive code changes.

## Expectations

- Keep the codebase warning-free.
- Add or update tests for functional changes.
- Run formatting before opening a pull request.
- Run clang-tidy for non-trivial C++ changes.
- Keep public headers documented and stable.
- Use `bash scripts/build.sh --profile perf` or `bash scripts/build.sh --profile callgrind` when investigating regressions.

## Releasing

The version lives in `vcpkg.json` and nowhere else.

1. Bump `version` in `vcpkg.json` and merge that change.
2. Rehearse the release with `gh workflow run release.yml`.
   A manual run builds, packages and checksums every target and keeps the result as workflow artifacts, without publishing anything.
3. Tag the commit as `v<version>` and push the tag.
   The release workflow refuses a tag that does not match `vcpkg.json`.

A tag of the form `v1.2.3` is published as a stable release.
Anything with a suffix, such as `v1.2.3-rc.1`, is published as a prerelease.

Release notes are generated from merged pull requests and grouped by label, as configured in `.github/release.yml`.

Set the repository variable `PUBLISH_DOCKER_IMAGE` to `true` to also push a multi-arch image to GitHub Container Registry on each release.
