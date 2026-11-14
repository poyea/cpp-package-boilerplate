FROM mcr.microsoft.com/devcontainers/cpp:3-ubuntu26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ccache \
        clang-22 \
        clang-format-22 \
        clang-tidy-22 \
        curl \
        doxygen \
        g++ \
        gdb \
        git \
        git-lfs \
        graphviz \
        lld-22 \
        lldb-22 \
        ninja-build \
        pkg-config \
        python3 \
        python3-pip \
        valgrind \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-22 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-22 100 \
    && update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-22 100 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages "cmake>=4.3"

# The distro default g++ is below the 16.1 floor, so configuring in the
# container would fail the version gate. The alternatives make plain gcc/g++
# resolve to 16.1.
COPY scripts/install_gcc.sh /tmp/install_gcc.sh
RUN bash /tmp/install_gcc.sh \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-16 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-16 100 \
    && g++ --version \
    && rm -rf /var/lib/apt/lists/* /tmp/install_gcc.sh
