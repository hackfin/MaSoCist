The MaSoCist environment 
-------------------------------------------------------------------------

[![Docker build status](https://img.shields.io/docker/cloud/build/hackfin/masocist)](https://hub.docker.com/r/hackfin/masocist/builds)


<info@section5.ch>
---
(**Ma**rtin's **SoC** **I**nstancing and **S**imulation/Synthesis **T**oolchain)

a.k.a. "Make it hurt!"

The MaSoCist distribution enables you to quickly design, maintain,
document and automatically create a family of Soft core featured System
on Chip solutions. It may therefore hurt less for you.

The MaSoCist is currently supported as docker image for local or cloud deployment only
(previous LXC support dropped). This opensource-version currently supports:

  * Co-Simulation with GHDL
  * A limited set of virtual boards and CPU architectures
  * Compiling source code for various architectures
  * Simple, hand-woven continous integration testing for hardware/software

Synthesis in the cloud is not yet supported. Integration is planned, once VHDL
open source synthesis is sufficiently tested.
However, all VHDL code is synthesizeable for typical FPGA scenarios.

Quick evaluation
------------------

Here's a short howto to set up an environment ready to play with. For example, running
a virtual RISC-V with a virtual UART console.

You can try this (for instance) in the browser at

https://labs.play-with-docker.com

Register yourself a Docker account login and just playing in your online sandbox
(time limit applies). You'll need to build and copy some files from contrib/docker
to the remote Docker machine instance.
Add a new machine instance in the left panel. Then use the two-liner:

    docker run -it hackfin/masocist

(wait a bit, then when you see the Virtual COM message, proceed:)

    wget https://section5.ch/downloads/masocist_sfx.sh && sh masocist_sfx.sh && make all run-pyrv32
    
After building the relevant tools, the virtual processor will boot and the terminal is fired
up to talk to it. When you see the 'Booting beatrix' message, you should get a prompt. Try the
'h' command followed by return to get help:

    # h

When you exit minicom by hitting `Ctrl+A`, then `q`, the simulation will be
terminated.


Building from scratch
-----------------------

Because dependencies have become complex, the only supported method to build the
MaSoCist environment is currently using the Dockerfile supplied in contrib/docker.

Run 'make dist' inside contrib/docker, this will create a file `masocist_sfx.sh`
Copy the following files to the Docker working directory (in the above docker playground
this works by dragging them onto the Playground browser shell window):

 `Dockerfile init-pty.sh run-tests.sh`

Build the container and run it:

    docker build . -t masocist .

    docker run -it -v/root:/usr/local/src masocist

Copy `masocist_sfx.sh` to the Docker machine and run, inside the running
container's home dir (/home/masocist):

    sudo sh /usr/local/src/masocist_sfx.sh

Now pull and build all necessary packages:

    make all

Run the virtual CPU demo, for example for pyrv32 or neo430:

    make clean run-pyrv32

    make clean run-neo430


If nothing went wrong, the simulation for the selected CPU will be built
and started with a virtual UART and SPI simulation. A minicom terminal will
connect to that UART and you'll be able to speak to the 'bare metal'
shell, for example, you can dump the content of the virtual SPI flash by:

    s 0 1

Again, use `Ctrl+A` followed by `q` to terminate the console and simulation.

Building a (virtual) board
-------------------------------

Enter the masocist source directory, typically in $HOME/src/vhdl/masocist.

1. Choose a configuration from an available set:

       make which

2. select a configuration, e.g. 'virtualboard':

       make virtualboard

This would build all `$(BUILD_DUTIES)`, which are typically 'sim' for
Simulation:

    make all

If you change the configuration, you may have to clean the simulation (in
worst case twice, if the kconfig tool decides to reconfigure):

    make clean all

3.  Build files for synthesis:

    make -C syn clean all

4. Open the project in syn/<FPGA_VENDOR>/<PLATFORM>

If files need to be added, you may use the TCL scripts that are generated
when running 'make' for synthesis.

5. Synthesize and hope for success :-)

Important: The build procedure for simulation builds the source differently
than for synthesis (-DSIMULATION flag). Make sure to rebuild explicitely
for synthesis, otherwise your system may boot up incorrectly with the
simulation specific program code.

----------------------------------------------------------------------------
LICENSING NOTES
----------------

The licensing of the MaSoCist distribution depends on its package tag.

As the author has made the experience, that opensource licenses are
not always respected when it comes to hardware designs, there is no such
thing as GPL (Gnu Public License) for this code, plus, it would very much
complicate development under a dual licensing scheme.

If you have received an 'opensource' distribution, the following rules apply:

NONCOMMERCIAL USAGE:
- You can use it for educational purposes or non-commercial home projects
- You will not get much free support, but you may of course feed back bugs
- You are encouraged to publish your changes, but noone will force you to it

COMMERCIAL USAGE:
- If you use the code in a commercial environment, you are free to do so,
  but you are *required* to publish changes made to the MaSoCist code base,
  including your own code that depends on MaSoCist functionality.
- If you are making a product that you are re-licensing or re-selling to
  others, you will need to acquire a license for the IP you use.

If you wish to have a maintained custom package, you will have to sign up
for a license agreement. This entitles you for a distribution tag. In this
case, you are completely free to keep further development proprietary,
EXCEPT changes made to the ghdlex package. Note that you also have to follow
the GHDL license agreements for distribution of simulation executables.

----------------------------------------------------------------------------
SIMULATION NOTES
-------------------

Simulation of some boards may require libraries that are not included
in the MaSoCist, because they are vendor specific. There may be several
solutions:

- Obtain necessary files from your local FPGA tool installation and create
  a GHDL library. Use the -P option to GHDL to specify the search path
  to the GHDL config file.
- Try the `CONFIG_EMULATE_PLATFORM_IP` option
- Use a virtual board config that is fully vendor IP independent

For example, when you receive an error message like this:
```
  ../hdl/plat/breakout_top.vhdl:16:9: cannot find resource library "machxo2"
```

you have to create a file `lattice/machxo2-obj93.cf` somewhere using
the rule:

```make

MACHXO2_VHDL = $(wildcard $(LATTICE_SIM)/machxo2/src/*.vhd)

lattice/machxo2-obj93.cf: $(MACHXO2_VHDL)
        [ -e lattice ] || mkdir lattice
        ghdl -i --workdir=lattice --work=machxo2 $(MACHXO2_VHDL)

```

where `LATTICE_SIM` is the directory of your simulation VHDL files, like:

```
  /usr/local/diamond/3.1_x64/cae_library/simulation/vhdl/
```

Then set the LIBGHDL variable in `vendor/default/local_config.mk`
to the directory where you created lattice/machxo2-obj93.cf, like:

```make
LIBGHDL = $(HOME)/src/vhdl/lib/ghdl
```

----------------------------------------------------------------------------
CONFIGURATION NOTES
--------------------

Note: The MaSoCist setup allows you to configure plenty of options that
may NOT WORK and will require you to look into implementation details.
Also, it may happen that some cores or options are just not supported
by the distribution you have. Especially the opensource version is
somewhat restricted to minimize support.

Therefore, a few thumb rules:

- Altering the peripheral I/O is safe.
- When changing the 'SoC device description', also check if 'Enable map prefix'
  needs to be set. This is described in detail in the developer documentation.
- For the Zealot CPU, you can make changes in the 'ZPU configuration' to some
  extent (see also developer documentation)
- Avoid changes in the TAP configuration. It has just been tuned
  that it works.


----------------------------------------------------------------------------
DOCUMENTATION
-------------------

For all further information, see ```doc/```directory or visit the
MaSoCist home page at:

  https://section5.ch/index.php/documentation/masocist-soc/

There are two ways to build the documentation:

- Opensource: Install the **dblatex** package and run
  > dblatex opensource.xml

  Not all documentation can be built using this scheme.

- Full SDK: Simply run 'make' and the documentation for your platform
  will be built automatically.
