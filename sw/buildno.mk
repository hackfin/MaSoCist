PROG_BUILDNO = .buildno
BUILDNO = $(shell cat $(PROG_BUILDNO))

buildnumber:
	@[ -e  $(PROG_BUILDNO) ] ||  echo 0 > $(PROG_BUILDNO)
	@echo $$(($$(cat $(PROG_BUILDNO)) + 1)) > $(PROG_BUILDNO)
	@echo Incrementing build number to $$(cat $(PROG_BUILDNO))

.PHONY: buildnumber
