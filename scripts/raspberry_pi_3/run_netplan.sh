#!/bin/bash

function test_wlan_up {
  ip a | grep wlan0 | grep "state UP"
  return $?
}

function test_wlan_inet_up {
  ping -c1 rosnet.hopto.org
  return $?
}

test_wlan_up
wlan_up=$?

while [ $wlan_up -ne 0 ]; do {
	sleep 1;
	test_wlan_up
	wlan_up=$?
} done;

/usr/sbin/netplan apply;

sleep 5;

test_wlan_inet_up
wlan_inet_up=$?

if [ $wlan_inet_up -eq 0 ]; then
  ip a > /tmp/ip_a-`hostname`.out;
  scp -i /home/ubuntu/.ssh/id_rsa /tmp/ip_a-`hostname`.out  agustin@rosnet.hopto.org:/home/agustin/ip/ip_a-`hostname`_`date +%F-%T`.out
fi;

exit;

