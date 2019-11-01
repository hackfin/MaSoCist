FROM ghdl/ghdl:buster-gcc-7.2.0

RUN apt-get update --allow-releaseinfo-change ; \
	apt-get install -y xsltproc make git flex bison gperf wget bzip2 \
	libncurses-dev \
	python python-pip \
	minicom socat \
	screen gnupg sudo pkg-config autoconf libtool

# These are necessary to build netpp:
# RUN apt-get install -y libeditline-dev doxygen

RUN wget -qO - https://section5.ch/section5-apt.key | apt-key add - 

RUN echo "deb http://section5.ch/debian buster non-free" > /etc/apt/sources.list.d/section5.list

RUN apt-get update ; \
	apt-get install -y gensoc binutils-msp430 gcc-msp430 msp430-libc \
		zpu-toolchain netpp-dev netpp-python \
		riscv32-binutils riscv32-gcc riscv32-newlib-libc

# Install some python modules:
RUN pip install intelhex numpy

RUN useradd -u 1000 -g 100 -m -s /bin/bash masocist 
RUN echo "export LD_LIBRARY_PATH=\$HOME/src/vhdl/ghdlex/src:\$LD_LIBRARY_PATH" >> /home/masocist/.bashrc

RUN adduser masocist sudo
RUN echo "masocist ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/masocist-nopw

COPY init-pty.sh /usr/local/bin
COPY run-tests.sh /usr/local/bin
RUN chmod a+rx /usr/local/bin/init-pty.sh /usr/local/bin/run-tests.sh

USER masocist
WORKDIR /home/masocist

ENTRYPOINT ["/bin/bash"]
CMD ["/usr/local/bin/init-pty.sh"]
