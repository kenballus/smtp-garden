FROM debian:trixie-slim

WORKDIR /app

RUN apt -y update && apt -y upgrade && apt -y install make clang-17 llvm-17-dev lld-17 git python3-dev gcc-13-plugin-dev libclang-rt-17-dev gcc-13 g++-13 busybox vim

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100 \
 && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100 \
 && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-17 100 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100

RUN rm -rf /var/lib/apt/lists/*
