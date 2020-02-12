#/bin/bash 
: ${IMG:=quay.io/piraeusdatastore/piraeus-client:latest}

docker run --rm \
    -e LS_CONTROLLERS=${LS_CONTROLLERS} \
    -v /etc/linstor:/etc/linstor:ro \
    ${IMG} \
    $@

