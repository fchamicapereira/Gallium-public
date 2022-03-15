FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y cmake vim git tmux build-essential \
  llvm-10 libboost-all-dev libgtest-dev libelf-dev

RUN git clone https://github.com/Kaiyuan-Zhang/Gallium-public.git

WORKDIR Gallium-public

RUN cd compiler && mkdir build && cd build && cmake .. && make -j
RUN tar zxvf click-llvm-ir.tar.gz
RUN rm click-llvm-ir.tar.gz

CMD ["/bin/bash"]