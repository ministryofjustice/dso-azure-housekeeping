#!/bin/bash
# Script that deletes all un-managed disks. This script iterates over all storage accounts in your default subscription
# Set deleteUnattachedVHDs=1 if you want to delete unattached VHDs
# Set deleteUnattachedVHDs=0 if you want to see the details of the unattached VHDs
deleteUnattachedVHDs=1

storageAccountIds=$(az storage account list --query [].[id] -o tsv)

for id in ${storageAccountIds[@]}
do
    connectionString=$(az storage account show-connection-string --ids $id --query connectionString -o tsv)
    containers=$(az storage container list --connection-string $connectionString --query [].[name] -o tsv)
    for container in ${containers[@]}
    do
        blobs=$(az storage blob list -c $container --connection-string $connectionString --query "[?properties.blobType=='PageBlob' && ends_with(name,'.vhd')].[name]" -o tsv)
        for blob in ${blobs[@]}
        do
            leaseStatus=$(az storage blob show -n $blob -c $container --connection-string $connectionString --query "properties.lease.status" -o tsv)
            if [ "$leaseStatus" == "unlocked" ]
            then
                if (( $deleteUnattachedVHDs == 1 ))
                then
                    echo "Deleting VHD: "$blob" in container: "$container" in storage account: "$id
                    az storage blob delete --delete-snapshots include  -n $blob -c $container --connection-string $connectionString
                    echo "Deleted VHD: "$blob" in container: "$container" in storage account: "$id
                else
                    echo "StorageAccountId: "$id" container: "$container" VHD: "$blob
                fi
            fi
        done
    done
done
