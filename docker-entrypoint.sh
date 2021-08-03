#!/bin/sh
LOG_FILE=~/watchman.log
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

watchman -o $LOG_FILE watch-project /app
echo "${JSON_TRIGGER}" | watchman -j

tail -f $LOG_FILE
