# Contributing

## Local workflow

1. Configure, build and test with `cmake --workflow --preset debug`.
2. Format with `bash scripts/format.sh`.
3. Run static analysis with `cmake --workflow --preset tidy`.
4. For dependency-manager validation use `cmake --workflow --preset debug-vcpkg`.
5. Build the benchmarks with `cmake --workflow --preset benchmarks` and run them when performance-sensitive code changes.

## Expectations

- Keep the codebase warning-free.
- Add or update tests for functional changes.
- Run formatting before opening a pull request.
- Run clang-tidy for non-trivial C++ changes.
- Keep public headers documented and stable.
- Build with `cmake --workflow --preset profile` and run the benchmarks under `perf` or `valgrind --tool=callgrind` when investigating regressions.

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
