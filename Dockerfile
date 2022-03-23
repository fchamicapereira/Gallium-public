FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

RUN apt-get update
RUN apt-get install -y cmake vim git tmux build-essential \
  libboost-all-dev libgtest-dev libelf-dev python

RUN apt-get install -y llvm-10 clang-10
RUN ln -s /usr/bin/clang++-10 /usr/bin/clang++
RUN ln -s /usr/bin/clang-10 /usr/bin/clang

# # Needed for llvm-6.0/clang-6.0, llvm-7/clang-7, llvm-8/clang-8
# RUN git clone https://github.com/Z3Prover/z3.git
# RUN cd z3 && python scripts/mk_make.py && cd build && make -j$(nproc) && make install

# LLVM 9
# ../../click/click-llvm-ir.old/ele_ll/tcpudp/fastudpsrcip6.ll:124:75: error: expected ')' at end of argument list
# define dso_local void @_ZN16FastUDPSourceIP6C2Ev(%class.FastUDPSourceIP6* %0) unnamed_addr #0 align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) !dbg !2944 {
#                                                                           ^


RUN mkdir Gallium-public
COPY . /Gallium-public

WORKDIR Gallium-public

ENV CXX=/usr/bin/clang++
ENV CC=/usr/bin/clang

RUN cd compiler && mkdir build && cd build && cmake .. && make -j$(nproc)
RUN cd extractor && mkdir build && cd build && cmake .. && make -j$(nproc)

RUN git clone https://github.com/kohler/click.git
# RUN cd click; git checkout 0be6b1471176d8f0d8c2f01579ba8486d14bd638
# # Necessary to build click on linux kernels > 5.2:
# RUN sed -i '54 i #include <linux/sockios.h>' click/elements/userlevel/fromdevice.cc
# RUN sed -i '38 i #include <linux/sockios.h>' click/elements/userlevel/rawsocket.cc

# Generate include/config.h
RUN cd click && ./configure

RUN tar zxf click-llvm-ir.tar.gz -C click/
RUN rm click-llvm-ir.tar.gz
RUN ln -s ./click/click-llvm-ir ./click-llvm-ir

# Let's keep a copy to compare the static and the generated ones
RUN cp -r click/click-llvm-ir click/click-llvm-ir.old

# For some reason, it will not compile this element,
# so we just remove it (hopefuly it isn't important...)
RUN sed -i '/indextreesiplookup.cc/d' click-llvm-ir/elements.txt

# I cannot find the source code for this element anywhere...
RUN sed -i '/myrewritermod.cc/d' click-llvm-ir/elements.txt

# Bug fix and compile custom element
RUN sed -i '100 i /*' click-llvm-ir/my_ele/tcpudp/myrewriter.cc
RUN sed -i '109 i */' click-llvm-ir/my_ele/tcpudp/myrewriter.cc
RUN cp -r click-llvm-ir/my_ele/* click/elements/

# Include click files
RUN sed -i 's/dummy_inc/include/g' click-llvm-ir/Makefile

# Generate LLVM IR for the click elements
RUN cd click-llvm-ir && make clean && make -j$(nproc)

CMD ["/bin/bash"]
