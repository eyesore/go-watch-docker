#!/bin/sh

rm -R /dist/*

cp -R /dist-include/* /dist

# TODO use env file for build location?
go get && go build -tags "netgo osusergo" -o /dist/app -v main.go

exit $?
