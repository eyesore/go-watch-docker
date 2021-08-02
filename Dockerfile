FROM golang:1.16.6-alpine AS runtime
MAINTAINER Trey Jones "trey@cortexdigitalinc.com"

ENV WATCHMAN_VERSION '4.9.0'
ENV BUILD_SCRIPT '/usr/local/bin/build-and-run.sh'
ENV ENTRYPOINT_SCRIPT 'docker-entrypoint.sh'
ENV ENTRYPOINT_PATH "/usr/local/bin/${ENTRYPOINT_SCRIPT}"

# alternative entrypoint that will build to dist and copy additional files if present
ENV DIST_ENTRYPOINT '/usr/local/bin/build-for-deploy.sh'

# vcs used by `go get` | python for pywatchman
RUN apk add --update --no-cache	git mercurial subversion

###################################
FROM runtime as builder
RUN apk add --update --no-cache --virtual build-deps python3-dev make \
	gcc g++ automake autoconf linux-headers \
	bash  libtool openssl-dev

# install watchman
RUN mkdir -p /build/watchman
ADD https://github.com/facebook/watchman/archive/v${WATCHMAN_VERSION}.zip     /build/watchman

# note the expression `./autogen.sh || autoconf` :
# this ignores an erroneous error in autogen.sh that is not friendly to alpine
RUN cd /build/watchman && \
    unzip v${WATCHMAN_VERSION}.zip && \
    cd watchman-${WATCHMAN_VERSION} && \
    ./autogen.sh || autoconf && \
    ./configure --enable-lenient && \
    make && \
    make install

############
FROM runtime AS release
COPY --from=builder /usr/local/bin/watchman* /usr/local/bin/

# runtime dirs?
COPY --from=builder /usr/local/var/run/watchman /usr/local/var/run/watchman

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
