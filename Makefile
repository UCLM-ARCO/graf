# -*- mode: makefile-gmake; coding: utf-8 -*-
DESTDIR ?= ~

all:

XSL_DIR=$(DESTDIR)/usr/lib/graf/xsl

install:
	install -vd $(DESTDIR)/usr/bin
	install -v -m 555 mkexam.py $(DESTDIR)/usr/bin/mkexam
	install -vd $(XSL_DIR)
	install -v -m 666 xsl/exam_gen.xsl $(XSL_DIR)/
	install -v -m 666 xsl/latex_view.xsl $(XSL_DIR)/
