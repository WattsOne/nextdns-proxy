#!/bin/bash
wget -q https://dns4me.net/api/v2/get_hosts/hosts/$1 -O /config/dns4me.hosts
/etc/init.d/dnsmasq force-reload