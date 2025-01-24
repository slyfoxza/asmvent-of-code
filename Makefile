UNAME_MACHINE ?= $(shell uname --machine)
ifeq ($(UNAME_MACHINE),x86_64)
export ARCHITECTURE := x86-64
export ASFLAGS := -mmnemonic=intel -mnaked-reg -msyntax=intel
export MARCH := -march=native
else ifeq ($(UNAME_MACHINE),aarch64)
export ARCHITECTURE := aarch64
export MARCH := -march=native
else ifeq ($(UNAME_MACHINE),riscv64)
export ARCHITECTURE := riscv64
export AS := riscv64-linux-gnu-as
export CC := riscv64-linux-gnu-gcc
export MARCH := -march=rv64id
else
$(error Unsupported machine type $(UNAME_MACHINE))
endif

export CFLAGS ?= -O3

subdirs := $(wildcard 20??-??/)

.PHONY: all clean $(subdirs)
all: $(subdirs)
clean: $(subdirs)
$(subdirs):
	$(MAKE) -C $@ $(MAKECMDGOALS)
