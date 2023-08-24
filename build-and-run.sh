#!/bin/sh

PASSED_ARGS="${@}"

go get
go build -buildvcs=false -o /go/bin/app

RUN_CMD="/go/bin/app ${PASSED_ARGS}"
echo "run cmd: ${RUN_CMD}"
${RUN_CMD} &
