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

null_route() {
#
#	louzy detection of IPv4 or IPv6 address
#
	INET=`echo "$2" | sed 's/[0-9\.]//g'`
	if [ -z "$INET" ]
	then
		INET=""
		GW="127.0.0.1"
	else
		INET="-f inet6"
		GW="::1"
	fi

	if [ -x /sbin/ip ]
	then
		/sbin/ip $INET route $1 $2 via $GW dev lo
	else
		if [ ! -z "$INET" ]
		then
			INET="-A inet6"
		fi
		/sbin/route $INET $1 -host $2 gw $GW dev lo
	fi

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

		CMD="add"
		IP=$2
		;;

	del)
		logger -i -t shield-trigger -p auth.info "unblocking $2"

		CMD="del"
		IP=$2
		;;

	*)
		usage
		;;
esac

null_route "$CMD" "$IP"

# EOB
