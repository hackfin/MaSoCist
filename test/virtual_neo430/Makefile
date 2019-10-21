SOFTWARE = ../../sw
SIMULATION = ../../sim
SIM_OPTIONS = --max-stack-alloc=256

ELFFILE = $(SOFTWARE)/main.elf

RV32TEST_LOGFILE = rv32ui.log

all: run-test

$(SIMULATION)/net_virtual_neo430:
	$(MAKE) -C $(SIMULATION) clean all

run-test: $(SIMULATION)/net_virtual_neo430
	sh test_boot.sh $(notdir $<)
