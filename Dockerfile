FROM ubuntu:14.04
# Bro 2.4beta 
MAINTAINER Daniel Guerra <daniel.guerra69@gmail.com>

#prequisits
RUN apt-get update && DEBIAN_FRONTEND=noninteractive
RUN apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive
RUN apt-get -y  install libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev libclick-0.4-dev Ocl-icd-opencl-dev libboost-dev doxygen git libcurl4-gnutls-dev libgoogle-perftools-dev libgeoip-dev geoip-database rsync openssh-server pwgen cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

#prequisits from source

# ipsumdump
WORKDIR /tmp
RUN git clone --recursive https://github.com/kohler/ipsumdump.git
WORKDIR /tmp/ipsumdump
RUN ./configure
RUN make
RUN make install

#bro 2.4beta
WORKDIR /tmp
RUN wget https://www.bro.org/downloads/beta/bro-2.4-beta.tar.gz
RUN tar xvf bro-2.4-beta.tar.gz
WORKDIR /tmp/bro-2.4-beta
RUN ./configure
RUN make all
RUN make install
WORKDIR /tmp/bro-2.4-beta/aux/plugins/elasticsearch
RUN ./configure
RUN make
RUN make install

#clean the dev packages 
RUN apt-get -y remove libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev libclick-0.4-dev ocl-icd-opencl-dev libboost-dev libcurl4-gnutls-dev libgeoip-dev cmake make gcc g++ flex bison libssl-dev python-dev swig zlib1g-dev
RUN apt-get -y autoremove

#cleanup apt & build action
WORKDIR /tmp
RUN rm -rf *

WORKDIR /var/cache/apt
RUN rm -rf *

WORKDIR /var/log
RUN rm -rf *

#prepare ssh dir use -v my-ssh:/root/.ssh
WORKDIR /root
RUN mkdir .ssh
RUN chown 700 .ssh

#set sshd config for key based authentication
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config

EXPOSE 22
EXPOSE 47761
EXPOSE 47762

#start sshd
CMD [“exec”,“/usr/sbin/sshd”,“-D”]
