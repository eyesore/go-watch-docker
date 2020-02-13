FROM golang:1.13-alpine
MAINTAINER Trey Jones "trey@cortexdigitalinc.com"

ENV WATCHMAN_VERSION '4.9.0'
ENV BUILD_SCRIPT '/usr/local/bin/build-and-run.sh'
ENV ENTRYPOINT_SCRIPT 'docker-entrypoint.sh'
ENV ENTRYPOINT_PATH "/usr/local/bin/${ENTRYPOINT_SCRIPT}"

# alternative entrypoint that will build to dist and copy additional files if present
ENV DIST_ENTRYPOINT '/usr/local/bin/build-for-deploy.sh'

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

# mount here for inputs
VOLUME /app

# mount here for outputs when building for deploy
VOLUME /dist

# all contents will be recursively copied to /dist when building for deploy
VOLUME /dist-include

COPY docker-entrypoint.sh "${ENTRYPOINT_PATH}"
COPY build-and-run.sh "${BUILD_SCRIPT}"
COPY build-for-deploy.sh "${DIST_ENTRYPOINT}"

RUN chmod +x "${BUILD_SCRIPT}" && chmod +x "${ENTRYPOINT_PATH}" && chmod +x "${DIST_ENTRYPOINT}"

WORKDIR /app
ENTRYPOINT "${ENTRYPOINT_PATH}"
