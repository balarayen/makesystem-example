# Makefile
#
# Copyright (C) 2017, Makesystem, Balamurugan Souppourayen
#
# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.
#

TOPTARGETS := local clean install uninstall

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)

$(SUBDIRS):
	@if [ -f $@/Makefile ]; \
        then \
        cd $@ && $(MAKE) $(MAKECMDGOALS); \
        fi;

.PHONY: $(TOPTARGETS) $(SUBDIRS)

