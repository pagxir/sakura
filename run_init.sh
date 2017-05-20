#!/bin/bash

echo "========================================================================"
echo ""
echo server: $ENVOVERLAY_FILE $AUTHORIZED_KEYS
echo ""
echo " Please remember the password!"
echo "========================================================================"

build_ssh_keys() {

	if [ "${AUTHORIZED_KEYS}" = "**None**" ]; then
		return;
	fi

	echo "=> Found authorized keys"
	mkdir -p /root/.ssh
	chmod 700 /root/.ssh
	touch /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
	IFS=$'\n'
	arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")

	for x in $arr do
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

build_ssh_keys
AUTHORIZED_KEYS=**None**

if echo ${DOCKER_HOOK_URL} | grep http; then
    wget -O docke_hook.rc $DOCKER_HOOK_URL;
    . docker_hook.rc
fi;

build_ssh_keys

for hook in $INIT_HOOKS; do
	$hook;
done

exec $INIT $INIT_OPTS
