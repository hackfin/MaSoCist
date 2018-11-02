# Rules to create a TCL file to ease adding sources to projects:

# If path is absolute, skip PROJECT_PREFIX output:

proj_%.tcl:
	@echo "# TCL script for ISE file import" > $@
	@for i in $(PROJECTFILES); do \
		if expr match $$i '^/.*' > /dev/null; then \
			echo xfile add \"$$i\" >> $@; \
		else \
			echo xfile add \"$(PROJECT_PREFIX)$$i\" >> $@; \
		fi; \
	done
	echo lib_vhdl new "zpu" >> $@; \
	for i in $(SYN_LIBFILES-y) ; do \
		echo xfile add \"$(PROJECT_PREFIX)$$i\" -lib_vhdl \"zpu\" >> $@; \
	done
	@echo Generated TCL file $@
	@echo -----------------------------------------------------------------
	@echo Run \"source \<path_to_file\>.tcl\" inside ISE to add the files to
	@echo a new project.
	@echo -----------------------------------------------------------------

