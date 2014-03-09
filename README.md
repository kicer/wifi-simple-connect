WiFi Simple Connect
===================

DESCRIPTION
-----------
	WiFi connect script, use uci-style configure file.
	use wpa_passphrase/wpa_supplicant/dhclient/ifconfig/ip to make connect,
	use awk to parse configure file.
	

INSTALL
-----------
	# make install

USAGE
-----------
	# ./wifi.sh [list|connect [ssid]|stop]

FILES
-----------
	/etc/config/wireless, /lib/functions/uci.sh, /var/run/wireless.connect
