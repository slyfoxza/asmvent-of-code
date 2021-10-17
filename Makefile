uname_machine := $(shell uname -m)
ifeq ($(uname_machine),x86_64)
include Makefile.x86-64
else
$(error Unsupported machine type $(uname_machine))
endif
