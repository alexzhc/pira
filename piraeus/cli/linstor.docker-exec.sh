# this script avoids creating container when running each linstor command.
#!/bin/sh

_docker_exec() {
    docker exec -it -e LS_CONTROLLERS=${LS_CONTROLLERS} piraeus-client $@
}

_docker_run_d() {
    echo "* Creating docker container"
    docker rm -f piraeus-client
    docker run -d --name piraeus-client \
              -v /etc/linstor:/etc/linstor:ro \
              --entrypoint tail \
              ${IMG:=quay.io/piraeusdatastore/piraeus-client} \
              -f /dev/null
    docker ps -af "name=piraeus-client"
    echo "* Linstor client version:"
    _docker_exec linstor -v
}

if [ "$1" = "--do-install" ]; then
    _docker_run_d
elif _docker_exec linstor --no-utf8 $@; then
    exit 0
elif [ $? = '1' ]; then
    _docker_run_d
    _docker_exec linstor --no-utf8 $@
    echo "* Next run will be much faster"
fi

