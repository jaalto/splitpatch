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
#       Generate manual page form Perl POD file.

ifneq (,)
    This makefile requires GNU Make.
endif

PACKAGE = splitpatch
RM      = rm --force

ifdef OPT_SHORT
    RM = rm -f
endif

all:
	$(MAKE) OPT_SHORT=$(OPT_SHORT) --file pod2man.mk PACKAGE=$(PACKAGE) makeman

clean:
	$(RM) *.1

.PHONY: all clean

# End of file
