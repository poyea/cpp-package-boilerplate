FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        g++-16 \
        ninja-build \
        python3-pip \
    && pip3 install --break-system-packages cmake \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc-16 CXX=g++-16

WORKDIR /workspace
COPY . .

RUN cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCPP_PACKAGE_BOILERPLATE_BUILD_TESTS=OFF \
        -DCPP_PACKAGE_BOILERPLATE_BUILD_BENCHMARKS=OFF \
        -DCPP_PACKAGE_BOILERPLATE_BUILD_DOCS=OFF \
    && cmake --build build --parallel

FROM ubuntu:24.04 AS runtime

COPY --from=builder /workspace/build/src/cpp_package_boilerplate_cli /usr/local/bin/cpp_package_boilerplate

ENTRYPOINT ["/usr/local/bin/cpp_package_boilerplate"]
