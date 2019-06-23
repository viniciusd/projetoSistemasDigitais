FROM ghdl/ghdl:ubuntu18-llvm-5.0

MAINTAINER Mario Barbareschi <mario.barbareschi@unina.it>

RUN apt-get update && \ 
    apt-get -y upgrade && \
    apt-get -y install cmake make git gtkwave

ADD ./ /opt
