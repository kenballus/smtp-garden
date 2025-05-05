FROM debian:trixie-slim

WORKDIR /app

RUN apt -y update && apt -y upgrade && apt -y install make clang-17 llvm-17-dev lld-17 git python3-dev gcc-13-plugin-dev libclang-rt-17-dev gcc-13 g++-13 busybox vim ncat net-tools procps tcpdump

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100 \
 && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100 \
 && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-17 100 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/clang-17 100

RUN useradd --create-home user1 && useradd --create-home user2 \
 && mkdir -p /home/user1/Maildir/{cur,new,tmp} && mkdir -p /home/user2/Maildir/{cur,new,tmp} \
 && chmod -R 744 /home/user1 && chmod -R 744 /home/user2 \
 && rm -rf /var/lib/apt/lists/*

