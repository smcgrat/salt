#!/bin/bash
# install and configure salt on Ubuntu 14.04

# install dependencies
apt-get install salt-minion -y

# firewall
saltmaster=""
saltmasterip=""
iptables -I INPUT -s $saltmasterip -m state --state new -m tcp -p tcp --dport 4505 -j ACCEPT
iptables -I INPUT -s $saltmasterip -m state --state new -m tcp -p tcp --dport 4506 -j ACCEPT
iptables-save > /etc/iptables.rules
# assumption is that salt will be used to congure the host to make firewall rules persistent after reboot
# by using shorewall in our environment. Saving a copy of the iptables rules just in case though

# minion configuration
minionfile=/etc/salt/minion
if [ -e $minionfile ]
then
	sed -e -i 's/#master: salt/master: salt.tchpc.tcd.ie/' /etc/salt/minion
elif [ ! -e $minionfile ]
then
	echo "master: $saltmaster" > $minionfile
	chown root:root $minionfile
	chmod 644 $minionfile
fi

mastercheck=$(grep 'master:' /etc/salt/minion)
echo "Configured salt master = $mastercheck"

update-rc.d salt-minion enable
service salt-minion restart

exit 0
