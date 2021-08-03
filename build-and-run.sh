#!/bin/sh

PIDFILE=/var/run/app
PASSED_ARGS="${@}"

go get
go build -o /go/bin/app

if [ $? -eq 0 ]; then
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        echo "Stopping running process: $PID"
        kill -KILL $PID
        rm $PIDFILE
    fi

    RUN_CMD="/go/bin/app ${PASSED_ARGS}"
	echo "run cmd: ${RUN_CMD}"
	${RUN_CMD} &

    if [ $? -eq 0 ]; then
        echo $! > $PIDFILE
    fi
fi
