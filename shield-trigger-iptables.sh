#! /bin/sh
#
#	shield-trigger.sh	WJ107
#
#   pam_shield 0.9.4  WJ107
#   Copyright (C) 2007  Walter de Jong <walter@heiho.net>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

run_iptables() {
#
#	louzy detection of IPv4 or IPv6 address
#
	IPT=`echo "$2" | sed 's/[0-9\.]//g'`
	if [ -z "$IPT" ]
	then
		IPT=iptables
	else
		IPT=ip6tables
	fi

#
#	CUSTOMIZE THIS RULE
#
#	$1 is the iptables command: -A or -D
#	$2 is the IP number
#
#	* put in the correct chain name (pam_shield or INPUT)
#	* put in the correct network interface name (eth0)
#	* put in the correct port number (22 is ssh)
#	* add additional rules for additional services as needed
#
	"$IPT" "$1" INPUT -i eth0 -p tcp -s "$2" --destination-port 22 -j pam_shield

#	mail -s "[security] pam_shield blocked $2" root <<EOF
#Another monkey kept off our backs ...
#EOF
}


### usually no editing is needed beyond this point ###


usage() {
	echo "shield-trigger.sh WJ107"
	echo "usage: ${0##*/} [add|del] <IP number>"
	echo
	echo "shield-trigger.sh is normally called by the pam_shield PAM module"
	exit 1
}


PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [ -z "$2" ]
then
	usage
fi

case "$1" in
	add)
		logger -i -t shield-trigger -p auth.info "blocking $2"

		CMD="-A"
		IP=$2
		;;

	del)
		logger -i -t shield-trigger -p auth.info "unblocking $2"

		CMD="-D"
		IP=$2
		;;

	*)
		usage
		;;
esac

run_iptables "$CMD" "$IP"

# EOB
