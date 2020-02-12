# This script avoids creating container when running each linstor command.
# But it is still slower than linstor.runc.sh.

#!/bin/sh
IMG=quay.io/piraeusdatastore/piraeus-client:latest

echo "$@" > /etc/linstor/.cmd

echo "export ${LS_CONTROLLERS}" > /etc/linstor/.env

_create_container() {
    [ -z $2 ] || IMG=$2
    docker rm piraeus-client
    docker create --name piraeus-client \
              -v /etc/linstor:/etc/linstor:ro \
              --entrypoint bash \
              ${IMG} \
              -c 'source /etc/linstor/.env; linstor $( cat /etc/linstor/.cmd )'
}

if [ "$1" == "--do-upgrade" ]; then
    _create_container
    echo '-v' > /etc/linstor/.cmd
    docker start -a piraeus-client
elif ! docker start -a piraeus-client; then
    _create_container
    docker start -a piraeus-client
fi

