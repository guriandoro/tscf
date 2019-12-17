#!/bin/bash

function test_wlan_inet_up {
  ping -c1 rosnet.hopto.org
  return $?
}

while true; do {
  test_wlan_inet_up
  wlan_up=$?

  if [ $wlan_up -ne 0 ]; then
    date
    /root/run_netplan.sh > /tmp/run_netplan-`date +%F-%T`.out 2>&1
    sleep 60;
  else
    sleep 10;
  fi
} done;

