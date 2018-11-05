FROM debian:latest

MAINTAINER Guoxing Pei <pagxir@gmail.com>

RUN apt-get update
RUN apt-get install -y socat vim wget tmux openssh-server
RUN apt-get install -y pwgen netcat curl net-tools
RUN apt-get install -y locales mosh
RUN apt-get autoremove
RUN rm -rf /var/lib/apt/lists/* 
RUN apt-get clean

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN grep '^PermitRootLogin yes' /etc/ssh/sshd_config || \
	sed -ri '$s/$/\nPermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir -p /var/run/sshd
	
RUN sed -i '/zh_CN.UTF-8/s/^[^a-z]//' /etc/locale.gen
RUN sed -i '/en_US.UTF-8/s/^[^a-z]//' /etc/locale.gen
RUN locale-gen

RUN touch /root/firstrun
RUN echo 'root:root' |chpasswd

WORKDIR /root
ADD run_init.sh /root
ADD set_root_pw.sh /root

RUN chmod +x /root/run_init.sh /root/set_root_pw.sh

EXPOSE 80
EXPOSE 8000/udp

ENV DOCKER_HOOK_URL **NONE**
ENV AUTHORIZED_KEYS **NONE**
ENTRYPOINT /root/run_init.sh
