uname_machine := $(shell uname -m)
ifeq ($(uname_machine),x86_64)
export ARCHITECTURE := x86-64
export ASFLAGS := -mmnemonic=intel -mnaked-reg -msyntax=intel
else ifeq ($(uname_machine),aarch64)
export ARCHITECTURE := aarch64
export AS := gcc10-as
export CC := gcc10-cc
else
$(error Unsupported machine type $(uname_machine))
endif

subdirs := $(wildcard 20??-??/)

.PHONY: all clean $(subdirs)

all: $(subdirs)

clean: $(subdirs)

$(subdirs):
	$(MAKE) -C $@ $(MAKECMDGOALS)
