#!/bin/sh
# Add hostname in hosts to avoid "Unable to resolve host <hostname>"
vmName=$(cat /etc/hostname)
nameResolution="127.0.0.1 $vmName"
sudo sed -i "1s/.*/$nameResolution/" /etc/hosts
sudo systemctl stop systemd-resolved 
myDns=168.63.129.16
sudo sed -i "s/#DNS=/DNS=$myDns/" /etc/systemd/resolved.conf
sudo sed -i "s/#DNSStubListener=yes/DNSStubListener=no/" /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Expse Google DNS server for name resolution
# echo "nameserver 168.63.129.16" | sudo tee /etc/resolv.conf > /dev/null

# Setup the variables for the environment
azure_dns=168.63.129.16
cloud_domain=dev.devstack.euw.adz.cloud.vwgroup.com
onprem_domain=aws.vwg
on_prem_dns1=10.222.20.201
on_prem_dns2=10.222.20.184

#Install dependencies and updates
sudo apt update -y
sudo apt install -y unbound

touch /var/log/unbound

cat << EOF > ./unbound.conf
remote-control:
		control-enable: no

server:
		val-permissive-mode: no
		ipsecmod-enabled: no
		ipsecmod-hook: no
		val-log-level: 2
		chroot: ""
		username: "unbound"
		directory: "/etc/unbound"
		logfile: "/var/log/unbound.log"
		log-time-ascii: yes
		log-queries: yes
		do-not-query-address: 127.0.0.1
		do-not-query-address: ::1
		unwanted-reply-threshold: 10000000
		rrset-roundrobin: yes
		statistics-interval: 0
		interface-automatic: yes
		verbosity: 9
		num-threads: 4
		port: 53
		do-ip4: yes
		do-ip6: no
		do-udp: yes
		do-tcp: yes
		interface: 0.0.0.0
		interface: 127.0.0.1
		access-control: 143.164.0.0/16 allow_snoop
		access-control: 11.0.0.0/8 allow_snoop
		access-control: 10.0.0.0/8 allow_snoop
		do-not-query-localhost: no
		so-reuseport: yes

forward-zone:
		name: ${cloud_domain}
		forward-addr: ${azure_dns}
forward-zone:
		name:  ${onprem_domain}
		forward-addr: ${on_prem_dns1}
		forward-addr: ${on_prem_dns2}

EOF

#Stop systemd-resolved process as it blocks port53
#sudo systemctl stop systemd-resolved
#sudo systemctl disable systemd-resolved

#Update Unbound Configuration File
cp ./unbound.conf /etc/unbound/unbound.conf

#Install Unbound as a Service and Execute
sudo systemctl enable unbound
sudo systemctl stop unbound
sudo systemctl start unbound
sudo echo $(sudo systemctl status unbound) > /tmp/unbound.status.txt
