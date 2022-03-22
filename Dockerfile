FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y cmake vim git tmux build-essential \
  llvm-10 clang-6.0 libboost-all-dev libgtest-dev libelf-dev

RUN mkdir Gallium-public
COPY . /Gallium-public

WORKDIR Gallium-public

ENV CXX=/usr/bin/clang++-6.0
ENV CC=/usr/bin/clang-6.0

RUN ln -s /usr/bin/clang++-6.0 /usr/bin/clang++
RUN ln -s /usr/bin/clang-6.0 /usr/bin/clang

RUN cd compiler && mkdir build && cd build && cmake .. && make -j
RUN cd extractor && mkdir build && cd build && cmake .. && make -j

RUN git clone https://github.com/kohler/click.git
RUN cd click && ./configure && make install
RUN tar zxf click-llvm-ir.tar.gz -C click/
RUN rm click-llvm-ir.tar.gz

RUN ln -s ./click/click-llvm-ir ./click-llvm-ir

# For some reason, it will not compile this element,
# so we just remove it (hopefuly it isn't important...)
RUN sed -i '/indextreesiplookup.cc/d' click-llvm-ir/elements.txt

# Let's also recompile the custom element
RUN sed -i '29 i ELEMENT_SRCS += tcpudp/myrewriter.cc' click-llvm-ir/Makefile

RUN cd click-llvm-ir && make -j 

CMD ["/bin/bash"]