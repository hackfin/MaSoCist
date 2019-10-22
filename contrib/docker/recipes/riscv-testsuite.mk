# This checks out a riscv test suite fork plus environment
# and builds the test suite executables
#
# These are downloaded by tests/*/emulation.py onto the simulation
# target and verified.
#
# (c) 2019 hackfin@section5.ch
#

TESTSUITE = $(HOME)/src/EXTERN/riscv-tests

TESTSUITE_REPO = https://github.com/hackfin/riscv-tests

TESTSUITE_ENV_REPO = https://github.com/hackfin/riscv-test-env

TESTSUITE_BUILD = $(HOME)/build/riscv-tests

$(TESTSUITE):
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@) && \
	git clone $(TESTSUITE_REPO)

$(TESTSUITE)/env/s5: | $(TESTSUITE)
	cd $(TESTSUITE) && \
	git checkout masocist && \
	git submodule update --init --recursive

$(TESTSUITE)/configure: $(TESTSUITE)/env/s5
	cd $(dir $<) && git checkout masocist
	cd $(TESTSUITE) && autoconf

$(TESTSUITE_BUILD)/config.status: $(TESTSUITE)/configure
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@) && \
	$<  -with-xlen=32

$(TESTSUITE_BUILD)/Makefile: $(TESTSUITE_BUILD)/config.status

$(TESTSUITE_BUILD)/isa/rv32ui-s5-lhu: $(TESTSUITE_BUILD)/Makefile
	cd $(dir $<) && make isa
	
all: $(TESTSUITE_BUILD)/isa/rv32ui-s5-lhu
