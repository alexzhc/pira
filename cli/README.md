# CLI scripts
## Overview
Linstor CLI is available in both piraeus-server and piraeus-client images: the former for deployment; the latter for standalone usage. 

## Installation
On a kubernetes node where `kubectl` works, usually a master node
```
$ cat > /usr/local/bin/linstor << 'EOF'
kubectl -n kube-system exec piraeus-controller-0 -- linstor $@
EOF

$ chmod +x /usr/local/bin/linstor
```
Now, test it by running
```
$ linstor node list
```

## CLI on non-k8s nodes

### Set controller address

For linstor-cli to work locally, it must be pointed to piraeus-controller's REST API address, either by environmental variable `LS_CONTROLLERS` or configuration file `/etc/linstor/linstor-client.conf`. Multiple addresses are supported for failover purpose.

For example
```
$ export LS_CONTROLLERS = 192.168.176.151:3370,192.168.176.152:3370,192.168.176.153:3370
```
or
```
$ cat > /etc/linstor/linstor-client.conf <<EOF
[global]
controllers = 192.168.176.151:3370,192.168.176.152:3370,192.168.176.153:3370
EOF
```

### Method 1: docker run

* linstor.docker-run.sh

This script is simply a `docker run` command.
However, `docker run` copies image each time when starting a container, which may add a couple seconds before actually executing linstor-cli. 

### Method 2: docker exec

* linstor.docker-exec.sh

This trick runs a piraeus-client container in the background and then run `docker exec` to access the client tool. It copies image only when called for the first time, which help subsequent executions run much faster than by using `docker run`.

### Method 3: runc run

* linstor.runc-run.sh

This script utilizes RunC to run piraeus-client container. It extracts image by docker only when called for the first time. After that, docker does not involve in any execution.

## Speed test

Test shows linstor.runc.sh is the fastest method, even faster than linstor.kube.sh.

| Method                   | Speed |
| :------------------------|:------|
| # in controller pod      | 0.25s |
| runc run                 | 0.32s |
| kubectl exec             | 0.49s |
| docker exec              | 0.66s |
| docker run               | 1.98s |

>Result by averaging 10 executions of `linstor node list`