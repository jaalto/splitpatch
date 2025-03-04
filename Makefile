# -*- mode: makefile-gmake; -*-
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

SHELL           = /bin/sh
INSTALL		= install
# Use --long install(1) options by default
OPT_SORT	=

ifneq (,)
    This makefile requires GNU Make.
endif

ifeq ($(findstring install,$(INSTALL)),install)
    # "command" is in POSIX, more portable than which(1)
    ifeq (,$(shell command -v install))
        $(error FATAL: program install(1) not found in PATH)
    endif

    GNU := $(findstring GNU,$(shell install --version))
endif

ifeq (,$(GNU))
    $(info INFO: non GNU install(1) detected, switch to short options...)
    OPT_SHORT = short
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

RM		= rm --force
LN		= ln --symbolic

MAKE_OPT_CHDIR    = --directory
INSTALL_OPT_MODE  = --mode
INSTALL_OPT_MKDIR = --directory

ifneq (,$(OPT_SHORT))
    RM = rm -f
    LN = ln -s
    INSTALL_OPT_MODE  = -m
    INSTALL_OPT_MKDIR = -d
endif

INSTALL_BIN	= $(INSTALL) $(INSTALL_OPT_MODE) 755
INSTALL_MMKDIR	= $(INSTALL) $(INSTALL_OPT_MODE) 755 $(INSTALL_OPT_MKDIR)
INSTALL_DATA	= $(INSTALL) $(INSTALL_OPT_MODE) 644
INSTALL_SUID	= $(INSTALL) $(INSTALL_OPT_MODE) 4755

# all - Call target 'help'
.PHONY: all
all: help

.PHONY: help
help:
	@awk '/^# [^ -]+ - / {sub("^# ", ""); print}' $(MAKEFILE)

# doc - Generate documentation
.PHONY: doc
doc:
	$(MAKE) $(MAKE_OPT_CHDIR) man all

# install-man - Install manual pages to MANDIR1
.PHONY: install-man
install-man: doc
	# install-man
	$(INSTALL_MKDIR) $(MANDIR1)
	$(INSTALL_DATA) man/*.1 $(MANDIR1)

# install-bin - Install program to BINDIR
.PHONY: install-bin
install-bin:
	# install-bin
	$(INSTALL_MKDIR) $(BINDIR)
	$(INSTALL_BIN) $(BIN) $(BINDIR)/$(PACKAGE)

# install-bin - symlink program to BINDIR
.PHONY: install-bin-symlink
install-bin-symlink:
	# install-bin
	$(INSTALL_MKDIR) $(BINDIR)
	$(LN) $(BIN) $(BINDIR)/$(PACKAGE)/

# install - install program and manual pages
.PHONY: install
install: install-bin install-man

# uninstall - uninstall program and manual pages
.PHONY: uninstall
uninstall:
	$(RM) $(BINDIR)/$(PACKAGE)
	$(RM) $(MANDIR1)/$(PACKAGE).1

# clean - Clean generated files
.PHONY: clean
clean:
	# clean
	-rm --force *[#~] *.\#*
	$(MAKE) $(MAKE_OPT_CHDIR) man $@

# distclean - Clean all generated files
.PHONY: distclean
distclean: clean

# realclean - Clean totally all generated files
.PHONY: realclean
realclean: clean

# End of file
