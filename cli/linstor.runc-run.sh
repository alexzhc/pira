#!/bin/sh
: ${CLIENT_DIR:=/opt/piraeus/client}

_runc_run() {
    echo "LS_CONTROLLERS=${LS_CONTROLLERS} $@" \
        | runc run -b ${CLIENT_DIR}/oci $( uuidgen )
}

_create_oci() {
    echo "* Installing image \"${IMG}\" to ${CLIENT_DIR}/oci/rootfs"
    rm -fr ${CLIENT_DIR}/oci
    mkdir -vp ${CLIENT_DIR}/oci/rootfs
    cd ${CLIENT_DIR}/oci
    docker export $( docker create --rm ${IMG:=daocloud.io/piraeus/piraeus-client:latest.runc}  ) \
        | tar -xf - -C rootfs \
              --checkpoint=400 --checkpoint-action=exec='printf "\b=>"'
    echo -e "\b]]"
    tar -zxvf rootfs/oci.tgz
    echo "* Linstor client version:"
    _runc_run linstor -v
}

if [ "$1" = "--do-install" ]; then
    _create_oci
elif _runc_run linstor --no-utf8 $@; then
    exit 0
elif [ $? = '1' ]; then
    _create_oci
    _runc_run linstor --no-utf8 $@
    echo "* Next run will be much faster"
fi
