#
# Makefile
#

CC := g++

SRCDIR := .
MODULENAME := $(shell basename $(PWD))
DISTDIR := ../../dist/$(MODULENAME)

ifeq ($(BIN_TARGET),TRUE)
	TARGETDIR := $(DISTDIR)/bin
	EXECUTABLE := $(MODULENAME)
else
	TARGETDIR := $(DISTDIR)/lib
	EXECUTABLE := $(addprefix lib, $(MODULENAME))
	EXECUTABLE := $(addsuffix .so, $(EXECUTABLE))
endif

TARGET := $(TARGETDIR)/$(EXECUTABLE)

INSTALLDIR := ../../demo

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
	@echo $^
ifeq ($(BIN_TARGET),TRUE)
ifneq ($^,)
	@mkdir -pv $(TARGETDIR)
	@echo "Linking..."
	@echo "  Linking $(TARGET)"; $(CC) $^ -o $@ $(LIB)
endif
else
ifneq ($^,)
	@mkdir -pv $(TARGETDIR)
	@echo "Archiving..."
	@echo "  Archiving $(TARGET)"; $(CC) -shared $^ -o $@
endif
endif

all: local

local: $(TARGET)

$(DISTDIR)/%.o: %.$(SRCEXT)
	@echo $^
ifneq ($(BUILDLIST),)
	@mkdir -pv $(BUILDLIST)
else
	@mkdir -pv $(DISTDIR)
endif
	@echo "Compiling $<..."; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

clean_all: local_clean

local_clean: distclean

distclean:
	@echo "Cleaning $(TARGET)..."; $(RM) -r $(DISTDIR) $(TARGET)

install:
	@mkdir -pv $(INSTALLDIR)
	@echo "Installing $(EXECUTABLE)"; cp $(TARGET) $(INSTALLDIR)

clean:
	@echo "Removing $(EXECUTABLE)"; $(RM) $(INSTALLDIR)/$(EXECUTABLE)

.PHONY: all
.PHONY: local
.PHONY: clean

