# common.mk
#
# Copyright (C) 2017, Makesystem, Balamurugan Souppourayen
#
# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.
#

CC := g++

ROOTDIR := ../..
SRCDIR := .
MODULENAME := $(shell basename $(PWD))
DISTDIR := $(ROOTDIR)/dist/$(MODULENAME)

ifeq ($(BIN_TARGET),TRUE)
	TARGETDIR := $(DISTDIR)/bin
	EXECUTABLE := $(MODULENAME)
else
	TARGETDIR := $(DISTDIR)/lib
	EXECUTABLE := $(addprefix lib, $(MODULENAME))
	EXECUTABLE := $(addsuffix .so, $(EXECUTABLE))
endif

TARGET := $(TARGETDIR)/$(EXECUTABLE)

INSTALLDIR := $(ROOTDIR)/package

SRCEXT := cpp
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS := $(patsubst %,$(DISTDIR)/%,$(SOURCES:.$(SRCEXT)=.o))

INCDIRS := $(shell find * -name '*.h' -exec dirname {} \; | sort | uniq)
INCLIST := $(patsubst %,-I %,$(INCDIRS))
BUILDLIST := $(patsubst %,$(DISTDIR)/%,$(INCDIRS))

INC := $(INCLIST)
LIB := 

CFLAGS := -c
CFLAGS += -O2

$(TARGET): $(OBJECTS)
ifeq ($(BIN_TARGET),TRUE)
ifneq ($(OBJECTS),)
	@mkdir -pv $(TARGETDIR)
	@echo "Linking..."
	@echo "  Linking $(TARGET)"; $(CC) $^ -o $@ $(LIB)
endif
else
ifneq ($(OBJECTS),)
	@mkdir -pv $(TARGETDIR)
	@echo "Archiving..."
	@echo "  Archiving $(TARGET)"; $(CC) -shared $^ -o $@
endif
endif

local: $(TARGET)

$(DISTDIR)/%.o: %.$(SRCEXT)
	@echo $^
ifneq ($(BUILDLIST),)
	@mkdir -pv $(BUILDLIST)
else
	@mkdir -pv $(DISTDIR)
endif
	@echo "Compiling $<..."; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

clean:
	@echo "Cleaning $(TARGET)..."; $(RM) -r $(DISTDIR) $(TARGET)

install:
	@mkdir -pv $(INSTALLDIR)
	@echo "Installing $(EXECUTABLE)"; cp $(TARGET) $(INSTALLDIR)

uninstall:
	@echo "Removing $(EXECUTABLE)"; $(RM) $(INSTALLDIR)/$(EXECUTABLE)

.PHONY: local
.PHONY: clean
.PHONY: install
.PHONY: uninstall

