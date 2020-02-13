# Piraeus client scripts
## Installation
On a kubernetes node where `kubectl` works, usually the master node
```
$ install cli/linstor.kube.sh /usr/local/bin/linstor
```
Now, test it by running
```
$ linstor node list
```

\* This script is simply:

```
kubectl -n kube-system exec piraeus-controller-0 -- linstor $@
```

## Run client outside of kubernetes nodes

### Configure controller address

For client to work on non-k8s nodes, it must be pointed to piraeus-controller's REST API address, either by environment variable `LS_CONTROLLERS` or configuration file `/etc/linstor/linstor-client.conf`. Multiple addresses are supported for failover purpose. 

For example
```
$ export LS_CONTROLLERS = 192.168.176.151:3370,192.168.176.152:3370,192.168.176.153:3370
```
or
```
cat <<EOF > /etc/linstor/linstor-client.conf
[global]
controllers = 192.168.176.151:3370,192.168.176.152:3370,192.168.176.153:3370
EOF
```

### linstor.docker-run.sh 

This script is simply:
```
$ docker run 
    -e LS_CONTROLLERS=${LS_CONTROLLERS} \
    -v /etc/linstor:/etc/linstor:ro \
    ${IMG:=quay.io/piraeusdatastore/piraeus-client} \
    $@
```
However, `docker run` copies image each time when starting container, which makes the script very slow. 

### linstor.docker-exec.sh

This trick runs a piraeus-client container in the background and then run `docker exec` to access the client tool. It copies image only when called for the first time, which help subsequent executions run much faster than by using `docker run`.

### linstor.runc.sh

This script utilizes RunC to run piraeus-client container. It extracts image by docker only when called for the first time. After that, docker does not involve in any execution.

## Speed test

Test shows linstor.runc.sh is the fastest method, even faster than linstor.kube.sh.

Tested result by averaging 10 executions of `linstor node list`
```
* linstor.runc.sh           0.32s
* linstor.kube.sh           0.73s
* linstor.docker-exec.sh    0.66s
* linstor.docker-run.sh     1.98s
```
