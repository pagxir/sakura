#!/bin/bash

echo "========================================================================"
echo ""
echo server: $ENVOVERLAY_FILE $AUTHORIZED_KEYS
echo ""
echo " Please remember the password!"
echo "========================================================================"

build_ssh_keys() {

	if [ "${AUTHORIZED_KEYS}" = "**NONE**" ]; then
		return;
	fi

	echo "=> Found authorized keys"
	mkdir -p /root/.ssh
	chmod 700 /root/.ssh
	touch /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
	IFS=$'\n'
	arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")

	for x in $arr; do
		x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
		cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
			echo "$x" >> /root/.ssh/authorized_keys
		fi
	done

	return;
}

INIT=/usr/sbin/sshd
INIT_OPTS=-D
FIRST_RUN=$(test -f /root/firstrun && echo 1 || echo 0)

rm /boot/firstrun
[[ $FIRST_RUN -eq 1 ]] && build_ssh_keys

echo Port 8080 >> /etc/ssh/sshd_config
/etc/init.d/ssh start

[[ $FIRST_RUN -eq 0 ]] || test -z ${DOCKER_HOOK_INIT} || eval ${DOCKER_HOOK_INIT}

test -z ${DOCKER_HOOK_PRE} || eval ${DOCKER_HOOK_PRE}

if echo ${DOCKER_HOOK_URL} | grep http; then
    test -f docker_hook.rc || wget -O docker_hook.rc $DOCKER_HOOK_URL;
    . docker_hook.rc
fi;

test -z ${DOCKER_HOOK_POST} || eval ${DOCKER_HOOK_POST}

[[ $FIRST_RUN -eq 0 ]] || test -z ${DOCKER_HOOK_FINI} || eval ${DOCKER_HOOK_FINI}

/etc/init.d/ssh stop
sed -i '/Port 8080/d' /etc/ssh/sshd_config

exec $INIT $INIT_OPTS
