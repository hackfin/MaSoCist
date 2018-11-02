
GCC_VERSION = 7.2.0
VHDL_STD ?= 93c

# Make sure we get the rebuild rules right: '93c' results in suffix '93'
# Older ghdl releases don't respect that
ifeq ($(VHDL_STD),93c)
	VHDL_STD_SUFFIX = 93
else
	VHDL_STD_SUFFIX = $(VHDL_STD)
endif

ifdef MINGW32
include $(TOPDIR)/vendor/default/mingw32_config.mk
else
	DLLEXT = so
	ifdef TEST_GHDL
	GHDL_ARCH = x86_64-pc-linux-gnu

	BUILDDIR = /media/strubi/scratch/build
	
	TEST_EXTENSION = -test
	GHDL_SANDBOX = $(BUILDDIR)/ghdl-3.5/test/usr/local/

	GHDL_PREFIX = $(GHDL_SANDBOX)/lib/ghdl/

	GHDL = $(GHDL_SANDBOX)/bin/ghdl

	GHDL_LDFLAGS += \
		--GHDL1=$(GHDL_SANDBOX)/libexec/gcc/$(GHDL_ARCH)/$(GCC_VERSION)/ghdl1



	endif
	DUTIES = $(SIM_TOP)
endif

# The GHDL object library (locally built)
GHDLTARGET = $(notdir $(GHDL))
LIBGHDL ?= $(VHDL)/lib/$(GHDLTARGET)

ifndef WORKDIR
	WORKDIR = work-$(GHDLTARGET)
endif

# No workie for older GHDL versions, export GHDL_PREFIX instead
# GHDL_FLAGS += --PREFIX=$(GHDL_PREFIX)

export GHDL_PREFIX

GHDL_LDFLAGS += $(GHDL_FLAGS)
GHDL_LDFLAGS += $(GHDL_LIBFLAGS)

ifndef SAVFILE
SAVFILE = view.sav
endif

ifndef GHDL
GHDL=ghdl
endif

.PHONY: gsim gshow xref $(SIM_TOP)


gsim: $(SIM_TOP)
	$(GHDL) -r $(SIM_TOP) --stop-time=$(DURATION) --wave=$(SIM_TOP).ghw

$(SIM_TOP).exe: $(SIM_TOP)
	cp $< $@

# .PHONY: import

GHDL_FLAGS += --workdir=$(WORKDIR)
GHDL_FLAGS += --std=$(VHDL_STD)

$(WORKDIR)/work-obj$(VHDL_STD_SUFFIX).cf: $(GHDL_IMPORT_DEPENDENCIES)
	$(GHDL) -i $(GHDL_FLAGS) $(PROJECTFILES)

$(WORKDIR)/zpu-obj$(VHDL_STD_SUFFIX).cf: $(ZPU_VHDL)
	[ -e $(dir $@) ] || mkdir $(dir $@)
	$(GHDL) -i --workdir=$(dir $@) --work=zpu $(ZPU_VHDL)

$(WORKDIR)/ghdlex-obj$(VHDL_STD_SUFFIX).cf: $(GHDLEX)
	$(MAKE) -C $(GHDLEX) -f lib.mk PREFIX=$(GHDLTARGET) VHDL_STD=$(VHDL_STD) \
		GHDL=$(GHDL) \
		all

$(SIM_TOP): $(WORKDIR) $(WORKDIR)/work-obj$(VHDL_STD_SUFFIX).cf $(LIBDEPS)
	$(GHDL) -m $(GHDL_LDFLAGS) $(SIM_TOP)

gsim-%: $(WORKDIR) $(WORKDIR)/work-obj$(VHDL_STD_SUFFIX).cf $(PROJECTFILES) $(LIBDEPS)
	$(GHDL) -m $(GHDL_LDFLAGS) $*

gshow:
	gtkwave $(SIM_TOP).ghw $(SAVFILE)

xref:
	$(GHDL) --xref-html $(GHDL_FLAGS) $(GHDL_LIBFLAGS) $(PROJECTFILES)

$(WORKDIR):
	mkdir $(WORKDIR)

%.o: %.vhd
	$(GHDL) -a $(GHDL_FLAGS) $<

%.o: %.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<


$(SIM_TOP).prj:
	@for i in $(PROJECTFILES) ; do \
		echo vhdl work \"$$i\" >> $@; \
	done

clean::
	rm -f $(SIM_TOP) $(SIM_TOP).ghw
	rm -fr $(WORKDIR)

check:
	ls -l $(GHDL_PREFIX)
