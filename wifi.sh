#!/bin/sh

. ./uci.sh

usage() {
cat <<-EOF
Usage: $0 [list|connect [ssid|iface]|stop]

you must run it by root.
EOF
}

if [ `id -u` -ne 0 -o $# -lt 1 ]; then
	usage
	exit 0
fi

connect() {
	connect_file=/var/run/wireless.connect

	eval device=`_uci_config_get wireless.wifi-device.device`
	eval driver=`_uci_config_get wireless.wifi-device.driver`

	if [ -z "$device" -o -z "$driver" ]; then
		return 1
	fi

	cnt=`_uci_config_count wireless.wifi-iface`
	for i in `seq 1 $cnt`; do
		eval ssid=`_uci_config_get wireless.@wifi-iface[$i].ssid`
		eval iface=`_uci_config_get wireless.@wifi-iface[$i]`
		if [ -z "$1" -o x"$ssid" = x"$1" -o x"$iface" = x"$1" ]; then
			eval key=`_uci_config_get wireless.@wifi-iface[$i].key`
			eval proto=`_uci_config_get wireless.@wifi-iface[$i].proto`
			eval ipaddr=`_uci_config_get wireless.@wifi-iface[$i].ipaddr`
			eval netmask=`_uci_config_get wireless.@wifi-iface[$i].netmask`
			eval gateway=`_uci_config_get wireless.@wifi-iface[$i].gateway`
			eval dns=`_uci_config_get wireless.@wifi-iface[$i].dns`
			break
		fi
	done

	wpa_passphrase "$ssid" "$key" > "$connect_file"
	wpa_supplicant -B -i $device -c "$connect_file" -D$driver 2>/dev/null

	if [ "xdhcp" = x"$proto" ]; then
		dhclient -v $device
	elif [ "xstatic" = x"$proto" ]; then
		if [ ! -z "$ipaddr" -a ! -z "$netmask" ]; then
			ifconfig $device $ipaddr netmask $netmask
		fi
		if [ ! -z "$gateway" ]; then
			ip route add default via $gateway dev $device 2>/dev/null
		fi
		if [ ! -z "$dns" ]; then
			cat /dev/null > /etc/resolv.conf
			for ip in $dns; do
				echo "nameserver $ip" > /etc/resolv.conf
			done
		fi
	fi
}

list() {
	printf "%-12s\t%s\n" "iface" "ssid"
	printf "%-12s\t%s\n" "-----" "----"
	cnt=`_uci_config_count wireless.wifi-iface`
	for i in `seq 1 $cnt`; do
		eval iface=`_uci_config_get wireless.@wifi-iface[$i]`
		eval ssid=`_uci_config_get wireless.@wifi-iface[$i].ssid`
		printf "%-12s\t%s\n" "$iface" "$ssid"
	done
}

stop() {
	killall -9 wpa_supplicant
}

case "x$1" in
"xlist")
	list
	;;
"xconnect")
	connect "$2"
	;;
"xstop")
	stop
	;;
*)
	usage
	;;
esac
