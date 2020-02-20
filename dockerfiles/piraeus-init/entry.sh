#!/bin/bash -e
${INIT_DEBUG,,} && set -x

# drop files to /init
cp -r /files/* /init

# configure each component
if [[ "${THIS_POD_NAME}" =~ -etcd-[0-9]+$ ]]; then
    /init/bin/config-etcd.sh
elif [[ "${THIS_POD_NAME}" =~ -controller-[0-9a-z]{10}-[0-9a-z]{5}$ ]]; then
    /init/bin/config-controller.sh
elif [[ "${THIS_POD_NAME}" =~ -node-[0-9a-z]+$ ]]; then
    /init/bin/config-node.sh
else
    echo "Failed to identify the component"
    exit 1
fi
