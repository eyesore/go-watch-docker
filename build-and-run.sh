#!/bin/sh

PASSED_ARGS="${@}"

go get
go build -buildvcs=false -o /go/bin/app

if [ $? -ne 0 ]; then
	"build failed - halting"
	exit 1
fi

RUN_CMD="/go/bin/app ${PASSED_ARGS}"
echo "run cmd: ${RUN_CMD}"
${RUN_CMD} &
