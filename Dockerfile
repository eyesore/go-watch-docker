FROM golang:1.12-alpine
MAINTAINER Trey Jones "trey@eyesoreinc.com"

ENV WATCHMAN_VERSION '4.9.0'
ENV BUILD_SCRIPT '/usr/local/bin/build-and-run-go-app.sh'
ENV ENTRYPOINT_SCRIPT 'docker-entrypoint.sh'
ENV ENTRYPOINT_PATH "/usr/local/bin/${ENTRYPOINT_SCRIPT}"

RUN mkdir -p /build/watchman

# install watchman
ADD https://github.com/facebook/watchman/archive/v${WATCHMAN_VERSION}.zip     /build/watchman

# bash is used by autogen.sh, second line is new deps since after 4.7
# last line are tools used by `go get`
RUN apk add --update --no-cache python python-dev py-pip make gcc g++ automake autoconf linux-headers \
    bash libtool openssl-dev \
    git mercurial subversion  # used by `go get`

RUN cd /build/watchman && \
    unzip v${WATCHMAN_VERSION}.zip && \
    cd watchman-${WATCHMAN_VERSION} && \
    ./autogen.sh && \
    ./configure --enable-lenient && \
    make && \
    make install

RUN pip install pywatchman

RUN apk del python-dev py-pip automake autoconf linux-headers \
    bash libtool openssl-dev && \
    rm -R /build/watchman
# per watchman adjust /proc/sys/fs/inotify/max_* as needed - alpine defaults are already high

VOLUME /app

COPY watch_and_run.sh "${ENTRYPOINT_PATH}"
COPY run.sh "${BUILD_SCRIPT}"

RUN chmod +x "${BUILD_SCRIPT}" && chmod +x "${ENTRYPOINT_PATH}"

WORKDIR /app
ENTRYPOINT "${ENTRYPOINT_PATH}"
