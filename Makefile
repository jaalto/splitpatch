# -*- mode: makefile; -*-
#
#   Copyright
#
#	Copyright (C) 2014-2025 Jari Aalto <jari.aalto@cante.net>
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   Description
#
#       Makefile to package, install and generate documentation.
#	See "make help".

ifneq (,)
This makefile requires GNU Make.
endif

PACKAGE		= splitpatch
BIN		= bin/$(PACKAGE).rb

VERSION		=
MAKEFILE	= Makefile

DESTDIR		=
PREFIX		?= /usr
prefix          = $(PREFIX)
exec_prefix	= $(prefix)
man_prefix	= $(prefix)/share
mandir		= $(man_prefix)/man
bindir		= $(exec_prefix)/bin
sharedir	= $(prefix)/share

BINDIR		= $(DESTDIR)$(bindir)
DOCDIR		= $(DESTDIR)$(sharedir)/doc

# 1 = regular, 5 = conf, 6 = games, 8 = daemons
MANDIR		= $(DESTDIR)$(mandir)
MANDIR1		= $(MANDIR)/man1

INSTALL		= /usr/bin/install
INSTALL_BIN	= $(INSTALL) --mode=755
INSTALL_DATA	= $(INSTALL) --mode=644
INSTALL_SUID	= $(INSTALL) --mode=4755

RM		= rm --force
LN		= ln --symbolic --relative

# all - Call target 'doc'
.PHONY: all
all: doc

.PHONY: help
help:
	awk '/^# [^ -]+ - / {sub("^# [^ -]+ - ", ""); print}' $(MAKEFILE) | sort

# clean - Clean generated files
.PHONY: clean
clean:
	# clean
	-rm -f *[#~] *.\#*
	$(MAKE) -C man $@

# distclean - Clean all generated files
.PHONY: distclean
distclean: clean

# realclean - Clean totally all generated files
.PHONY: realclean
realclean: clean

# doc - Generate documentation
.PHONY: doc
doc:
	$(MAKE) -C man all

# install-man - Install manual pages to MANDIR1
.PHONY: install-man
install-man: doc
	# install-man
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) man/*.1 $(MANDIR1)

# install-bin - Install program to BINDIR
.PHONY: install-bin
install-bin:
	# install-bin
	$(INSTALL_BIN) -d $(BINDIR)
	$(INSTALL_BIN) $(BIN) $(BINDIR)/$(PACKAGE)

# install-bin - symlink program to BINDIR
.PHONY: install-bin-symlink
install-bin-symlink:
	# install-bin
	$(INSTALL_BIN) -d $(BINDIR)
	$(LN) $(BIN) $(BINDIR)/$(PACKAGE)/

# install - install program and manual pages
.PHONY: install
install: install-bin install-man

# uninstall - uninstall program and manual pages
.PHONY: uninstall
uninstall:
	$(RM) $(BINDIR)/$(PACKAGE)
	$(RM) $(MANDIR1)/$(PACKAGE).1

# End of file
