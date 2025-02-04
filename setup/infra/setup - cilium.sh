#!/bin/env bash

CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
CILIUM_CLI_VERSION="v0.16.23"
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz
tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz

### taint nodes so that application pods are not scheduled/executed until Cilium is deployed ###
kubectl taint nodes --all node.cilium.io/agent-not-ready:NoExecute

### setup cilium CNI ###
cat <<EOF | sudo tee /cilium-config.yaml
#k8sServiceHost: 10.0.0.65
#k8sServicePort: 6443

#hubble:
#  relay:
#    enabled: true

cni:
  chainingMode: portmap

ipam:
  mode: kubernetes
  operator:
    clusterPoolIPv4PodCIDRList:
    - 100.64.0.0/14 # 172.18.0.0/16
    clusterPoolIPv4MaskSize: 24
    #clusterPoolIPv6PodCIDRList:
    #- "fd18::/48"
    #clusterPoolIPv6MaskSize: 120
#ipv6.enabled: true
EOF

cat <<EOF | sudo tee /cilium-config.yaml
kubeConfigPath: /.kube/config

cni:
  chainingMode: portmap

ipam:
  mode: kubernetes
  operator:
    clusterPoolIPv4PodCIDRList:
    - 100.64.0.0/14
    clusterPoolIPv4MaskSize: 18

hostPort:
  enabled: true
EOF

#cilium install --list-versions
cilium install --version 1.15.5 --values /cilium-config.yaml

cilium status --wait


sudo netstat -tlnp
watch kubectl get all --all-namespaces


kubectl -n kube-system logs deployment/coredns -f

cilium connectivity test
kubectl -n cilium-test exec -it deployment/client -- sh
kubectl -n kube-system describe cm/cilium-config
