#!/bin/bash
## Script to set soft-delete flag on all keyvaults. 
## This allows us to recover all keyvaults for up to 90 days, if they're accidentally trashed.
## Set "softDelete" to '1' to actually set the soft delete flag (on line 7)

for i in `az account list -o tsv | cut -f 2`
do
  az account set --subscription $i;
  softDelete=0
  keyvaultIds=$(az keyvault list -o tsv | awk '{print $1}')
  for id in ${keyvaultIds[@]}
  do
     if (( $softDelete == 1 ))
     then
         echo "Setting soft delete flag on: "$id
         az resource update --id $id --set properties.enableSoftDelete=true
     else
         echo Listing keyvaults:
         echo $id
     fi
  done
done

