FROM ubuntu:26.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        ninja-build \
        python3-pip \
    && pip3 install --break-system-packages cmake \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/install_gcc.sh /tmp/install_gcc.sh
RUN bash /tmp/install_gcc.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/install_gcc.sh

ENV CC=gcc-16 CXX=g++-16

WORKDIR /workspace
COPY . .

RUN cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCPP_PACKAGE_BOILERPLATE_BUILD_TESTS=OFF \
        -DCPP_PACKAGE_BOILERPLATE_BUILD_BENCHMARKS=OFF \
        -DCPP_PACKAGE_BOILERPLATE_BUILD_DOCS=OFF \
        -DCPP_PACKAGE_BOILERPLATE_STATIC_RUNTIME=ON \
    && cmake --build build --parallel

FROM scratch AS release

ARG TARGETARCH

COPY ${TARGETARCH}/cpp_package_boilerplate_cli /usr/local/bin/cpp_package_boilerplate

ENTRYPOINT ["/usr/local/bin/cpp_package_boilerplate"]

FROM scratch AS runtime

COPY --from=builder /workspace/build/src/cpp_package_boilerplate_cli /usr/local/bin/cpp_package_boilerplate

ENTRYPOINT ["/usr/local/bin/cpp_package_boilerplate"]
