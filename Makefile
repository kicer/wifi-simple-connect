INSTALL = /usr/bin/install -c

all:

install:
	if [ ! -d /lib/functions ]; then mkdir -p /lib/functions; fi
	$(INSTALL) -m 755 uci.sh /lib/functions/uci.sh
	if [ ! -d /etc/config ]; then mkdir -p /etc/config; fi
	if [ ! -f /etc/config/wireless ]; then \
		$(INSTALL) -m 644 wireless /etc/config/wireless; \
	fi

uninstall:
	@rm -vf /lib/functions/uci.sh
