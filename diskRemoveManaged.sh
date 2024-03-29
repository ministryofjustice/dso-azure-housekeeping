#!/bin/bash
# Script to remove all unused managed disks in all subscriptions
for i in `az account list -o tsv | cut -f 2`
do
  az account set --subscription $i;
  deleteUnattachedDisks=1
  unattachedDiskIds=$(az disk list --query '[?managedBy==`null`].[id]' -o tsv)
  for id in ${unattachedDiskIds[@]}
  do
      if (( $deleteUnattachedDisks == 1 ))
      then

          echo "Deleting unattached Managed Disk with Id: "$id
          az disk delete --ids $id --yes
          echo "Deleted unattached Managed Disk with Id: "$id

      else
          echo $id
      fi
  done
done
