#!/bin/bash
# Usage: bash create-high-availability-vm-with-sets.sh <Resource Group Name>

date
# Create a Virtual Network for the VMs
echo '------------------------------------------'
echo 'Creating a Virtual Network for the VMs'
az network vnet create \
    --resource-group testexam\
    --name bePortalVnet \
    --subnet-name bePortalSubnet 

# Create a Network Security Group
echo '------------------------------------------'
echo 'Creating a Network Security Group'
az network nsg create \
    --resource-group testexam\
    --name bePortalNSG 

# Add inbound rule on port 80
echo '------------------------------------------'
echo 'Allowing access on port 80'
az network nsg rule create \
    --resource-group testexam\
    --nsg-name bePortalNSG \
    --name Allow-80-Inbound \
    --priority 110 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --description "Allow inbound on port 80."

# Create the NIC
for i in `seq 1 2 3`; do
  echo '------------------------------------------'
  echo 'Creating webNic'$i
  az network nic create \
    --resource-group testexam\
    --name webNic$i \
    --vnet-name bePortalVnet \
    --subnet bePortalSubnet \
    --network-security-group bePortalNSG
done 

# Create an availability set
echo '------------------------------------------'
echo 'Creating an availability set'
az vm availability-set create -n portalAvailabilitySet -g $RgName

# Create 3 VM's from a template
for i in `seq 1 2 3`; do
    echo '------------------------------------------'
    echo 'Creating webVM'$i
    az vm create \
        --admin-username azureuser \
        --resource-group testexam\
        --name webVM$i \
        --nics webNic$i \
        --image UbuntuLTS \
        --availability-set portalAvailabilitySet \
        --generate-ssh-keys \
        --custom-data cloud-init.txt
done

# Done
echo '--------------------------------------------------------'
echo '             VM Setup Script Completed'
echo '--------------------------------------------------------'
