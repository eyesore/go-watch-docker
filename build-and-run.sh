#!/bin/sh

PIDFILE=/var/run/app

go get
go build -o /go/bin/app

if [ $? -eq 0 ]; then
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        echo "Stopping running process: $PID"
        kill -KILL $PID
        rm $PIDFILE
    fi

    /go/bin/app start&

    if [ $? -eq 0 ]; then
        echo $! > $PIDFILE
    fi
fi
