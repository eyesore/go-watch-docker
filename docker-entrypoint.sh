#!/bin/sh

/usr/local/bin/build-and-run.sh&
watchman-make -p '**/*.go' --run='/usr/local/bin/build-and-run.sh'
