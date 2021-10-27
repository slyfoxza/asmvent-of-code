uname_machine := $(shell uname -m)
ifeq ($(uname_machine),x86_64)
export ARCHITECTURE := x86-64
else
$(error Unsupported machine type $(uname_machine))
endif

subdirs := $(wildcard 20??-??/)

.PHONY: all clean $(subdirs)

all: $(subdirs)

clean: $(subdirs)

$(subdirs):
	$(MAKE) -C $@ $(MAKECMDGOALS)
