#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	git reset HEAD --hard
	exec "$@"
fi
