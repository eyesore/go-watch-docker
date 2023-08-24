#!/bin/sh
# legacy env var allowed setting of command, but just use docker's CMD!
# THIS DOES NOTHING - is there a fix?
# JUST USE -e GWD_CMD for now
if [ -z $GWD_CMD ]; then
	# echo "using docker CMD as GWD_CMD: ${@}"
	GWD_CMD="${@}"
fi

watchexec --workdir /app -w /app -e .go -r "/usr/local/bin/build-and-run.sh ${GWD_CMD}"
