uname_machine := $(shell uname --machine)
ifeq ($(uname_machine),x86_64)
export ARCHITECTURE := x86-64
export ASFLAGS := -mmnemonic=intel -mnaked-reg -msyntax=intel
else ifeq ($(uname_machine),aarch64)
export ARCHITECTURE := aarch64
else
$(error Unsupported machine type $(uname_machine))
endif

export CFLAGS ?= -O3

subdirs := $(wildcard 20??-??/)

.PHONY: all clean $(subdirs)
all: $(subdirs)
clean: $(subdirs)
$(subdirs):
	$(MAKE) -C $@ $(MAKECMDGOALS)
