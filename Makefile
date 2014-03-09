INSTALL = /usr/bin/install -c

all:

install:
	if [ ! -d /lib/functions ]; then mkdir -p /lib/functions; fi
	$(INSTALL) -m 755 uci.sh /lib/functions/uci.sh

uninstall:
	@rm -vf /lib/functions/uci.sh
