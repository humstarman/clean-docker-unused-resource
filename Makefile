SHELL=/bin/bash
SCRIPTS=./scripts
GROUP=hosts

all: install

install:
	@${SCRIPTS}/mk-cronjob.sh -g ${GROUP}

clean:
	@${SCRIPTS}/mk-cronjob.sh -d
