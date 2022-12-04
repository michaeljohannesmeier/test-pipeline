#!/bin/bash
source ./env-vars.txt

echo "Creating resource group and vnet"
az group create --name $RG --location $LOCATION
az network vnet create \
    --name $VNET \
    --resource-group $RG\
    --location $LOCATION \
    --address-prefixes 172.10.0.0/16 \
    --subnet-name $SUBNET \
    --subnet-prefixes 172.10.1.0/24

# Master instance
echo "Creating Kubernetes Master"
for i in 0; do 
    echo "Creating Kubernetes Node ${i}"
    az vm create --name kube-master-${i} \
    --resource-group $RG \
    --location $LOCATION \
    --image UbuntuLTS \
    --admin-user $ADMINUSER \
    --ssh-key-values ~/.ssh/id_rsa.pub \
    --size Standard_DS2_v2 \
    --data-disk-sizes-gb 10 \
    --public-ip-sku Standard \
    --public-ip-address-dns-name kube-master
done

# Nodes intances

az vm availability-set create \
    --name $AVAIL_SET \
    --resource-group $RG

for i in 0; do 
    echo "Creating Kubernetes Node ${i}"
    az vm create --name kube-node-${i} \
        --resource-group $RG \
        --location $LOCATION \
        --availability-set $AVAIL_SET \
        --image UbuntuLTS \
        --admin-user $ADMINUSER \
        --ssh-key-values ~/.ssh/id_rsa.pub \
        --size Standard_DS2_v2 \
        --data-disk-sizes-gb 10 \
        --public-ip-sku Standard \
        --public-ip-address-dns-name kube-node-${i}
done

az vm list --resource-group $RG -d
