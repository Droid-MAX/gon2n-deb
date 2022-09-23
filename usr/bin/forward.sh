#!/bin/bash
PATH=/usr/local/sbin:/usr/sbin:/sbin:$PATH

if [ $EUID != 0 ]; then
	sudo "$0" "$@"
	exit $?
fi

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

ETH_IFACE=$2
EDGE_IFACE=$3

if [ -z $4 ]; then
	NET_CIDR="0.0.0.0/0"
else
	NET_CIDR=$4
fi

check_args(){
	if [ -z $ETH_IFACE ] || [ -z $EDGE_IFACE ]; then
		echo -e "[${RED}ERROR${NC}] missing arguments, please check your input!"
		exit 1
	fi
}

check_ipv4_forward(){
	if [ "$(cat /proc/sys/net/ipv4/ip_forward)" -eq 1 ]; then
		echo 1
	else
		echo 0
	fi
}

enable_ipv4_forward(){
	pre_checking_forward=$(check_ipv4_forward)
	if [ "$pre_checking_forward" -eq 0 ]; then
		echo 1 > /proc/sys/net/ipv4/ip_forward
	fi
}

check_iptables_rule_exists(){
	if [ -z "$(iptables -vL | grep -i $EDGE_IFACE)" ]; then
		echo 1
	else
		echo 0
	fi
}

add_iptables_rules(){
	pre_existing_rule=$(check_iptables_rule_exists)
	if [ "$pre_existing_rule" -eq 1 ]; then
		iptables -A FORWARD -i $EDGE_IFACE -o $ETH_IFACE -j ACCEPT
		iptables -A FORWARD -i $ETH_IFACE -o $EDGE_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
		iptables -t nat -A POSTROUTING -o $ETH_IFACE -s $NET_CIDR -j MASQUERADE
	else
		echo -e "[${YELLOW}INFO${NC}] iptables rules already exists on system"
		exit 1
	fi
}

remove_iptables_rules(){
	pre_existing_rule=$(check_iptables_rule_exists)
	if [ "$pre_existing_rule" -eq 0 ]; then
		iptables -D FORWARD -i $EDGE_IFACE -o $ETH_IFACE -j ACCEPT
		iptables -D FORWARD -i $ETH_IFACE -o $EDGE_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
		iptables -t nat -D POSTROUTING -o $ETH_IFACE -s $NET_CIDR -j MASQUERADE
	else
		echo -e "[${YELLOW}INFO${NC}] iptables rules already removed from system"
		exit 1
	fi
}

do_enable(){
	check_args
	enable_ipv4_forward
	add_iptables_rules
	echo -e "[${GREEN}INFO${NC}] ${EDGE_IFACE} traffic forward is enabled"
	exit 0
}

do_disable(){
	check_args
	remove_iptables_rules
	echo -e "[${GREEN}INFO${NC}] ${EDGE_IFACE} traffic forward is disabled"
	exit 0
}

case "$1" in
	enable)
		do_enable
		;;
	disable)
		do_disable
		;;
	*)
		echo "Usage: $0 {enable|disable} <eth interface, e.g: eth0> <edge interface, e.g: edge0> <network cidr, default: 0.0.0.0/0>"
		exit 1
		;;
esac
