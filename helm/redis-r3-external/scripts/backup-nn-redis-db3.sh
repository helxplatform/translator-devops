#!/bin/bash
#
# This script backs up all the RDB dumps for a particular
# version of NodeNorm from a set of RDB servers.
#

# Configuration
NN_VERSION="${NN_VERSION:-2024oct24}"
NN_NAMESPACE="${NN_NAMESPACE:-translator-dev}"

# Copy all the dump files.
function check_and_download() {
    name=$1
    echo == $name ==
    echo Disk space usage
    kubectl exec -n "$NN_NAMESPACE" "nn-redis-$NN_VERSION-$name-master-0" -- bash -c 'df -h | grep data'
    echo Files in /data -- should only be dump.rdb!
    kubectl exec -n "$NN_NAMESPACE" "nn-redis-$NN_VERSION-$name-master-0" -- bash -c 'ls -thor /data'
    kubectl exec -n "$NN_NAMESPACE" "nn-redis-$NN_VERSION-$name-master-0" -- bash -c 'md5sum /data/*'
    # Check RDB file.
    echo Checking RDB file.
    kubectl exec -n "$NN_NAMESPACE" "nn-redis-$NN_VERSION-$name-master-0" -- bash -c 'redis-check-rdb /data/dump.rdb'
    # Backup file.
    kubectl cp -n "$NN_NAMESPACE" "nn-redis-$NN_VERSION-$name-master-0:/data/dump.rdb" ./$name.rdb --retries 5 && \
        md5 ./$name.rdb && \
        gzip ./$name.rdb
}

# Download files
check_and_download "id-categories"
