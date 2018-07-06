#!/bin/bash
PID=$(ps aux | grep firefox | awk '{print $2}' | head -n 1)
if [[ -z "$PID" || "$#" -ne "1" ]]; then
    echo "Firefox not running or invalid args: $1"
    exit 1
fi

echo "Will $1 Firefox (PID=$PID)"
if [[ "$1" == "pause" ]]; then
    kill -SIGSTOP $PID
elif [[ "$1" == "resume" ]]; then
    kill -SIGCONT $PID
else
    echo "Invalid arg: $1"
    exit 1
fi

