#!/bin/bash

# Simple helpers to make an easy clickable link on console.
export LOCAL_ADDRESS="$(ip route get 1 | awk '{print $(NF-2);exit}')"
export PUBLIC_ADDRESS="$(curl ipinfo.io/ip)"
echo -e "\n\n################################################################################\n"
echo "Server running: http://$(hostname):7865"
echo "Server will be locally available at: http://$LOCAL_ADDRESS:7865"
echo -e "Server will be publicly available at: http://$PUBLIC_ADDRESS:7865\n"
echo -e "################################################################################\n\n"

if [ $# -eq 0 ]; then
	flags="--listen --preset realistic"
	echo "Start flags: $flags"
	exec /usr/bin/python entry_with_update.py $flags
else
	echo "Start flags: $@"
	exec /usr/bin/python entry_with_update.py "$@"
fi
