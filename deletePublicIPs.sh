#!/bin/bash
## Script to remove unused public IP addresses from all subscriptions in azure
## Set "deleteUnattachedIPs" to '0' to list all unused public IPs (on line 9)
## Set "deleteUnattachedIPs" to '1' to actually delete all unused public IPs. (on line 9)

for i in `az account list -o tsv | cut -f 2`
do
  az account set --subscription $i;
  deleteUnattachedIPs=1
  unattachedIpIds=$(az network public-ip list --query "[?ipConfiguration==null].[id]" -o tsv)
  for id in ${unattachedIpIds[@]}
  do
     if (( $deleteUnattachedIPs == 1 ))
     then

         echo "Deleting unattached NIC with Id: "$id
         az network public-ip delete --ids $id
         echo "Deleted unattached NIC with Id: "$id
     else
         echo $id
     fi
  done
done
