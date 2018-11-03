The MaSoCist environment 
-------------------------------------------------------------------------

<info@section5.ch>
---
(**Ma**rtin's **SoC** **I**nstancing and **S**imulation/Synthesis **T**oolchain)

a.k.a. "Make it hurt!"

The MaSoCist distribution enables you to quickly design, maintain,
document and automatically create a family of Soft core featured System
on Chip solutions. It may therefore hurt less for you.


Prerequisites
------------------

You need the build environment. Because dependencies have become complex,
a Dockerfile plus various build recipes to build the environment for you is
supplied in contrib/docker.

Here's a short howto to set up an environment ready to play with.
You can try this online at

https://labs.play-with-docker.com, for example.

Just register yourself a Docker account, login and start playing in your
online sandbox. You'll need to build and copy some files from contrib/docker
to the remote Docker machine instance.

Run 'make dist' inside contrib/docker, this will create a file masocist_sfx.sh
Copy Dockerfile and init-pty.sh to the Docker playground by dragging the files onto
the Playground browser shell window.

Build the container and run it:

    docker build -t masocist .

    docker run -it -v/root:/usr/local/src

Copy masocist_sfx.sh to the Docker machine and run, inside the running
container's home dir (/home/masocist):

    sudo sh /usr/local/src/masocist_sfx.sh

Now pull and build all necessary packages:

    make all

If nothing went wrong, the simulation for the neo430 CPU will be built
and started with a virtual UART and SPI simulation. A minicom terminal will
connect to that UART and you'll be able to speak to the neo430 'bare metal'
shell, for example, you can dump the content of the virtual SPI flash by:

    s 0 1

When you exit minicom by hitting `Ctrl+A`, then `q`, the simulation will be
terminated.

Quick start
------------

1. Choose a configuration from an available set:

> make which

  (select a configuration, e.g. 'virtualboard')

> make virtualboard

This would build all `$(BUILD_DUTIES)`, which are typically 'sim' for
Simulation:

> make all

If you change the configuration, you may have to clean the simulation (in
worst case twice, if the kconfig tool decides to reconfigure):

> make clean all

2.  Build files for synthesis:

> make -C syn clean all

3. Open the project in syn/<FPGA_VENDOR>/<PLATFORM>

If files need to be added, you may use the TCL scripts that are generated
when running 'make' for synthesis.

4. Synthesize and hope for success :-)

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
