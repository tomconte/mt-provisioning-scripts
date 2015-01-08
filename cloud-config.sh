#!/bin/sh

# cloud-init reference for Ubuntu:
# https://help.ubuntu.com/community/CloudInit
# We are using the "User-Data Script" format.
# It needs to be passed to "azure vm create" using e.g. --custom-data=cloud-config.sh

# Generate the GB locale (GSTQ!)

locale-gen en_GB.UTF-8

# Install packages

add-apt-repository -y ppa:ondrej/php5-oldstable
apt-get update -y
apt-get upgrade -y
apt-get install puppet -y
apt-get install ruby-stomp -y

wget http://turnkeylinux.mirrors.ovh.net/puppet-frozen/apt/pool/squeeze/main/m/mcollective/mcollective-common_2.2.4-1_all.deb http://turnkeylinux.mirrors.ovh.net/puppet-frozen/apt/pool/squeeze/main/m/mcollective/mcollective_2.2.4-1_all.deb
dpkg -i mcollective*

apt-get -f install -y

# Set the proper hostname and FQDN for facter

ip=$(hostname -I)
host=$(hostname)
fqdn=$host.cloudapp.net

echo $ip $fqdn $host >> /etc/hosts

# Puppet configuration

cat > /etc/puppet/puppet.conf <<EOF
[main]
vardir = /var/lib/puppet
logdir = /var/log/puppet
rundir = /var/run/puppet
ssldir = \$vardir/ssl

[agent]
pluginsync = true
report = true
ignoreschedules = true
#daemonize = false
certname = $fqdn
environment = production
#listen = true
server = puppet.tonictowers.com
EOF

puppet agent --test --waitforcert 2
