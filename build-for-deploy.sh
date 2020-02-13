#!/bin/sh

rm -R /dist/*

cp -R /dist-include/* /dist

go get && go build -tags "netgo osusergo" -o app -v main.go

exit $?
