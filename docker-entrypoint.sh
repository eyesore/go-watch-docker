#!/bin/sh
LOG_FILE=~/watchman.log

watchman -o $LOG_FILE watch-project /app
watchman -- trigger /app build '*.go' -- /usr/local/bin/build-and-run.sh

tail -f $LOG_FILE
