#!/bin/sh
# this method is experimental
IMG=daocloud.io/piraeus/piraeus-client:latest.runc
: ${CLIENT_DIR:=/opt/piraeus/client}

if [ "$1" = "--do-install" ] || [ "$1" = "--do-upgrade" ]; then
    [ -z $2 ] || IMG=$2
    echo "* Extracting image \"${IMG}\" to ${CLIENT_DIR}/oci/rootfs"
    rm -fr ${CLIENT_DIR}/oci
    mkdir -vp ${CLIENT_DIR}/oci/rootfs
    cd ${CLIENT_DIR}/oci
    docker export $( docker create --rm ${IMG} ) \
        | tar -xf - -C rootfs \
              --checkpoint=400 --checkpoint-action=exec='printf "\b=>"'
    echo -e "\b]]"
    mv -vf rootfs/runc ./
    mv -vf rootfs/config.json.template ./
else
    cd ${CLIENT_DIR}/oci
    CMD=$( echo \"linstor\",\"--no-utf8\",\"$@\" | sed 's/ /","/g' )
    cat config.json.template \
        | sed "s/_COMMAND_/${CMD}/; s#LS_CONTROLLERS=#&${LS_CONTROLLERS}#" \
        > config.json
    runc run $( uuidgen )
fi
