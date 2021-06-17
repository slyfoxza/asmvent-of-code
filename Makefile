uname_machine := $(shell uname -m)
ifeq ($(uname_machine),aarch64)
include Makefile.aarch64
else ifeq ($(uname_machine),armv7l)
include Makefile.armv7
else ifeq ($(uname_machine),x86_64)
include Makefile.x86-64
else
$(error Unknown machine type $(uname_machine))
endif
