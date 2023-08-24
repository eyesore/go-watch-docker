FROM golang:1.21.0-alpine3.18 AS runtime
MAINTAINER Trey Jones "trey@cortexdigitalinc.com"

ENV BUILD_SCRIPT '/usr/local/bin/build-and-run.sh'
ENV ENTRYPOINT_SCRIPT 'docker-entrypoint.sh'
ENV ENTRYPOINT_PATH "/usr/local/bin/${ENTRYPOINT_SCRIPT}"

# alternative entrypoint that will build to dist and copy additional files if present
ENV DIST_ENTRYPOINT '/usr/local/bin/build-for-deploy.sh'

# vcs used by `go get`
RUN apk add --update --no-cache	git mercurial subversion

###################################
FROM runtime as watcher

RUN apk add --update --no-cache cargo
RUN cargo install watchexec-cli

############
FROM runtime AS release

COPY --from=watcher /root/.cargo/bin/watchexec /usr/local/bin/watchexec

# increase from default max system watches
RUN echo 'fs.inotify.max_user_watches=65536' >  /etc/sysctl.d/inotify.conf

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
