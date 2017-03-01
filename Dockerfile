FROM ubuntu:14.10
MAINTAINER Guoxing Pei <pagxir@gmail.com>

WORKDIR /root
ADD set_root_pw.sh /root
ADD run_pre_hook.sh /root

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y socat vim wget tmux openssh-server git g++ build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen netcat curl net-tools
RUN apt-get autoremove
RUN apt-get clean

ENV PRE_HOOK_URL http://blog.oigle.cc/downloads/build_self_vpn.sh
ENV AUTHORIZED_KEYS **NONE**
ENV TZ "Asia/Shanghai"
ENV TERM xterm
ENV HOME /root

EXPOSE 22
EXPOSE 8000

RUN mkdir -p /var/run/sshd && sed -i \
		  -e "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" \
		  -e "s/PermitRootLogin without-password/PermitRootLogin yes/g" \
		  -e "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" \
		  -e "s/UsePAM yes/UsePAM no/g" \
		  /etc/ssh/sshd_config

RUN chmod +x /root/*.sh

ENTRYPOINT /root/run_pre_hook.sh
