#!/bin/sh
# Check the current connection status of network interfaces
# Then separate only the wlan interfaces
INTERFACES=$(nmcli -g device device)
INTERFACES=$(echo "$INTERFACES" | grep '^wlan[0-9]*$')

# Import the Tello SSIDs
. ./tellos1.config
echo "$SSID0"

# Ensure the current interfaces are disconnected from wifi networks
for i in $INTERFACES; do
	if [ "$i" = wlan0 ]; then
		:
	else
		nmcli device disconnect "$i"
	fi
done

# Connect to the Tellos
for i in $INTERFACES; do
	echo "$i"
	nmcli device wifi rescan
    for x in $SSID0; do
		if [ "$i" = wlan0 ]; then
			:
		else
			nmcli device wifi connect "$x" ifname "$i"
			RETURN=$?
			if [ $RETURN -eq 0 ]; then
				echo "Connected '$i' to '$x'. Moving forward."
				SSID0=$(echo $SSID0 | sed 's/'$x'//' )
				echo "New SSID List:"
				echo "$SSID0"
				break
			else
				echo "Not Connected."
			fi
		fi
	done
done

