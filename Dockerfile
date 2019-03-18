FROM golang:1.11-alpine
MAINTAINER Trey Jones "trey@eyesoreinc.com"

RUN mkdir -p /build/watchman

# install watchman
ADD https://github.com/facebook/watchman/archive/v4.7.0.zip     /build/watchman

RUN apk add --update --no-cache python python-dev py-pip make gcc g++ automake autoconf linux-headers \
    git mercurial subversion  # used by `go get`

RUN cd /build/watchman && \
    unzip v4.7.0.zip && \
    cd watchman-4.7.0 && \
    ./autogen.sh && \
    ./configure --enable-lenient && \
    make && \
    make install

RUN pip install pywatchman

RUN apk del python-dev py-pip automake autoconf linux-headers
# per watchman adjust /proc/sys/fs/inotify/max* as needed - trying defaults first

VOLUME /app

COPY watch_and_run.sh /entrypoint.sh
COPY run.sh /run.sh

RUN chmod +x /run.sh && chmod +x /entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
