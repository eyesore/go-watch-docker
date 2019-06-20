#!/bin/sh

/usr/local/bin/build-and-run-go-app.sh&
watchman-make -p '**/*.go' --run='/usr/local/bin/build-and-run-go-app.sh'
