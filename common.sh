#!/bin/sh

_uci_config_count() {
	[ $# -ne 1 ] && return 1

	file=/etc/config/`echo "$*" | awk -F. '{print $1}'`
	config=`echo "$*" | awk -F. '{print $2}'`

	[ ! -f "$file" ] && return 1

	awk "/^\s*config\s+$config/" "$file" | awk 'END {print NR}' 
}

_uci_config_get() {
	[ $# -ne 1 ] && return 1

	file=/etc/config/`echo "$*" | awk -F. '{print $1}'`
	config=`echo "$*" | awk -F. '{print $2}'`
	config_name=`echo "${config#@}" | awk 'BEGIN {FS="[@\\\[\\\]]"} {print $1}'`
	config_index=`echo "${config#@}" | awk 'BEGIN {FS="[@\\\[\\\]]"} {print $2}'`
	option=`echo "$*" | awk -F. '{print $3}'`

	[ ! -f "$file" ] && return 1
	[ -z "$config_index" ] && config_index=1

	config_nr=$(awk "/^\s*config\s+$config_name/ {printf NR \" \"}" "$file" | awk "{print \$$config_index}")
	config_next=$(awk "/^\s*config\s+\w*/ {if(NR > $config_nr) printf NR \" \"}" "$file" | awk '{print $1}')
	
	if [ ! -z "$config_next" ]; then
		awk "{if((NR>$config_nr) && (NR<$config_next)) "'print $0}' $file
	else
		awk "{if(NR>$config_nr) "'print $0}' $file
	fi | awk "/^\s*option\s+$option/ "'{$1=$1; print $0}' | awk "BEGIN {FPAT=\"([^ ]+)|('[^']+')\"} {print \$3}"
}

_uci_config_set() {
	# _uci_config_set wifi.wifi-iface[0].ssid "AP"
	[ $# -ne 2 ] && return 1

	file=/etc/config/`echo "$*" | awk -F. '{print $1}'`
	config=`echo "$*" | awk -F. '{print $2}'`
	config_name=`echo "${config#@}" | awk 'BEGIN {FS="[@\\\[\\\]]"} {print $1}'`
	config_index=`echo "${config#@}" | awk 'BEGIN {FS="[@\\\[\\\]]"} {print $2}'`
	option=`echo "$*" | awk -F. '{print $3}'`

	[ ! -f "$file" ] && return 1
}
