#!/bin/sh
LOG_FILE=~/watchman.log

# legacy env var allowed setting of command, but just use docker's CMD!
if [ -z $GWD_CMD ]; then
	echo "using docker CMD as GWD_CMD: ${@}"
	GWD_CMD="${@}"
fi

JSON_CMD=$(cat <<-EOF
{
	"name": "build-and-run",
	"append_files": false,
	"command": ["/usr/local/bin/build-and-run.sh", "${GWD_CMD}"],
	"expression": ["match", "**/*.go", "wholename"]
}
EOF
)

if [ ! -z $GWD_CMD_FILE ]; then
	echo "reading user supplied CMD file"
	JSON_CMD=$(cat "${GWD_CMD_FILE}")
fi

JSON_TRIGGER=$(cat <<-EOF
["trigger", "/app", ${JSON_CMD}]
EOF
)

echo "setting trigger: ${JSON_TRIGGER}"

watchman -o $LOG_FILE watch-project /app
echo "${JSON_TRIGGER}" | watchman -j

tail -f $LOG_FILE
