# -*- makefile-gmake -*-

DOC_DIR=doc
VERSION=0.0.1

EJABBERD_INCLUDE_DIR=/usr/lib/ejabberd/include

WIDTH=1024
#WIDTH=800
DPI=$(shell echo '90 * $(WIDTH) / 1024' | bc)

ifeq ($(shell uname -s),Darwin)
SED=gsed
else
SED=sed
endif

all: mod_rabbitmq.beam documentation

clean:
	rm -f mod_rabbitmq.beam
	rm -f build-stamp install-stamp

clean-doc:
	rm -rf doc/*

doc:
	mkdir ./doc

.PHONY: documentation
documentation: \
		doc/overview.edoc \
		doc/xmpp-amqp-gateway.png \
		doc/whole-network-1.png \
		doc/whole-network-2.png
	$(MAKE) doc
	erl -noshell \
		-eval 'edoc:application(mod_rabbitmq, ".", [])' \
		-run init stop
	$(SED) -e 's:\(<p><i>Generated by EDoc\), .*\(</i></p>\):\1\2:' -i doc/*.html

doc/overview.edoc: src/overview.edoc.in
	$(MAKE) doc
	$(SED) -e 's:%%VERSION%%:$(VERSION):g' < $< > $@

doc/%.png: src/%.svg
	inkscape --export-dpi=$(DPI) --export-png=$@ $<

%.beam: src/%.erl
	erlc -I $(EJABBERD_INCLUDE_DIR) $<

distclean: clean
