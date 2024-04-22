FROM debian:trixie-slim

WORKDIR /app

RUN apt -y update && apt -y upgrade && apt -y install make clang-17 llvm-17-dev lld-17 git python3-dev gcc-13-plugin-dev libclang-rt-17-dev gcc-13 g++-13 busybox vim ncat net-tools procps pkg-config libevent-dev libssl-dev autoconf automake bison libtool

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100 \
 && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100 \
 && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-17 100 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/clang-17 100

RUN rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/OpenSMTPD/OpenSMTPD.git && cd OpenSMTPD && ./bootstrap && ./configure && make && make install

RUN ln -s /usr/sbin/smtpctl sendmail && ln -s /usr/sbin/smtpctl send-mail && ln -s /usr/sbin/smtpctl mailq && ln -s /usr/sbin/smtpctl makemap && ln -s /usr/sbin/smtpctl newaliases
RUN mkdir /var/empty && useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd && useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq

RUN mkdir /etc/mail && touch /etc/mail/aliases
