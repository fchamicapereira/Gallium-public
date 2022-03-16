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

RUN cd compiler && mkdir build && cd build && cmake .. && make -j
RUN cd extractor && mkdir build && cd build && cmake .. && make -j

RUN tar zxvf click-llvm-ir.tar.gz
RUN rm click-llvm-ir.tar.gz

CMD ["/bin/bash"]