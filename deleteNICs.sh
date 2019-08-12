#!/bin/bash
# Script for deleting unused NICs. This does not iterate over subscriptions
# Set deleteUnattachedNics=1 if you want to delete unattached NICs
# Set deleteUnattachedNics=0 if you want to see the Id(s) of the unattached NICs
for i in `az account list -o tsv | cut -f 2`
do
  az account set --subscription $i;
  deleteUnattachedNics=1
  unattachedNicsIds=$(az network nic list --query '[?virtualMachine==`null`].[id]' -o tsv)
  for id in ${unattachedNicsIds[@]}
  do
     if (( $deleteUnattachedNics == 1 ))
     then

         echo "Deleting unattached NIC with Id: "$id
         az network nic delete --ids $id
         echo "Deleted unattached NIC with Id: "$id
     else
         echo $id
     fi
  done
done
