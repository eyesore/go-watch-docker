#!/bin/sh

/run.sh&
watchman-make -p '**/*.go' --make='/run.sh' -t goapp
