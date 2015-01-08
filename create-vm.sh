#!/bin/sh

# This script will automate the creating and provisioning of an Azure VM
# using the Azure CLI: http://azure.microsoft.com/en-us/documentation/articles/xplat-cli/
# and a cloud-init script to configure the VM for Puppet:
# https://github.com/Azure/azure-content/blob/master/articles/virtual-machines-how-to-inject-custom-data.md

VMNAME=$1
VMPORTS=$2

VMSIZE=Small
VMLOCATION="West Europe"
VMIMAGE=b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_5-LTS-amd64-server-20140927-en-us-30GB
VMUSER=azureuser

echo "creating VM ..."

azure vm create --custom-data=cloud-config.sh --vm-size=$VMSIZE --ssh=22 --vm-name=$VMNAME --location="$VMLOCATION" --userName=$VMUSER --ssh-cert=cert.pem --no-ssh-password $VMNAME $VMIMAGE

# Wait for VM to start -- give it 30 seconds

echo "sleeping for 30 seconds ..."
sleep 30

# Open endpoints

if [ "$VMPORTS" != "" ]; then
	IFS=':' read -a PORTS <<< "$VMPORTS"
	for i in "${PORTS[@]}"; do
		echo "opening port $i ..."
		azure vm endpoint create $VMNAME $i
	done
fi
