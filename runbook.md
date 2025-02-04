```bash
sudo lxc exec workload bash

cloud-init status --wait

## wait for cloud-init script finish and exec again into the workload VM

istioctl install --set profile=ambient --skip-confirmation

## install eZtunnel

REPO=arthursimas1/k8s-ebpf-offloading
VERSION=v0.1.1
INSTALL_PATH=/usr/local/bin/k8s-ebpf-offloading
sudo curl -L "https://github.com/${REPO}"\
"/releases/download/${VERSION}"\
"/k8s-ebpf-offloading-$(uname -s)-$(uname -m)" -o ${INSTALL_PATH}
sudo chmod +x ${INSTALL_PATH}

sudo k8s-ebpf-offloading


## open another terminal

## run the ping-echo workload

REPO=arthursimas1/k8s-ebpf-offloading
VERSION=v0.1.1
curl "https://raw.githubusercontent.com/${REPO}/${VERSION}"\
"/workloads/ping-echo/manifest.yml" -o- | kubectl apply -f-

kubectl logs -n workload-simple-ping-echo deployment.apps/ping

## remove the workload

kubectl delete ns/workload-ping-echo
```
