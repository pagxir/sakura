FROM debian:latest

MAINTAINER Guoxing Pei <pagxir@gmail.com>

RUN apt-get update && \
	apt-get install -y openssh-server && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir -p /var/run/sshd
	
EXPOSE 22

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y socat vim wget tmux openssh-server git g++ build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen netcat curl net-tools locales
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales mosh
RUN apt-get autoremove
RUN apt-get clean

RUN sed -i '/zh_CN.UTF-8/s/^#//' /etc/locale.gen
RUN sed -i '/en_US.UTF-8/s/^#//' /etc/locale.gen
RUN locale-gen

WORKDIR /root
ADD set_root_pw.sh /root
ADD run_pre_hook.sh /root

ENV PRE_HOOK_URL http://blog.oigle.cc/downloads/build_self_vpn.sh
ENV AUTHORIZED_KEYS **NONE**
ENV TZ "Asia/Shanghai"
ENV TERM xterm
ENV HOME /root

EXPOSE 8000/udp
EXPOSE 60001/udp

RUN chmod +x /root/*.sh

ENTRYPOINT /root/run_pre_hook.sh
