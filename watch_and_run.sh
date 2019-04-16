#!/bin/sh

/run.sh&
watchman-make -p '**/*.go' --run='/run.sh'
