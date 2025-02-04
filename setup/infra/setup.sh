#!/bin/env bash

ARCH="amd64"
if [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi

### general dependencies ###
sudo apt-get update
sudo apt-get -qq install -y net-tools socat conntrack

### enable overlay, br_netfilter kernel modules ###
cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

### enable ipv4/ip_forward ###
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
EOF

sudo sysctl --system

### install containerd ###
CONTAINERD_VERSION="1.7.18"
curl -L --fail --remote-name-all https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-${ARCH}.tar.gz
sudo tar Cxzvf /usr/local containerd-${CONTAINERD_VERSION}-linux-${ARCH}.tar.gz
sudo rm containerd-${CONTAINERD_VERSION}-linux-${ARCH}.tar.gz

curl -sSL "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" | sudo tee /usr/lib/systemd/system/containerd.service

sudo mkdir -p /etc/containerd/

cat <<EOF | sudo tee /etc/containerd/config.toml
version = 2

[grpc]
  address = "/var/run/containerd/containerd.sock"

[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.9"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
EOF

sudo systemctl enable --now containerd

### install runc ###
RUNC_VERSION="v1.1.12"
curl -L --fail --remote-name-all https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.${ARCH}
sudo install -m 755 runc.${ARCH} /usr/local/sbin/runc
rm runc.${ARCH}

### install CNI plugins ###
CNI_PLUGINS_VERSION="v1.3.0"
DEST="/opt/cni/bin"
sudo mkdir -p "$DEST"
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C $DEST -xz

### download cilium CNI ###
CILIUM_CLI_VERSION="v0.16.9"
sudo curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${ARCH}.tar.gz
sudo tar xzvfC cilium-linux-${ARCH}.tar.gz /usr/local/bin
sudo rm cilium-linux-${ARCH}.tar.gz

### install crictl ###
CRICTL_VERSION="v1.30.0"
DOWNLOAD_DIR="/usr/local/bin"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

### install helm ###
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh  --version v3.14.0
rm get_helm.sh

### install kubeadm, kubelet, kubectl ###
KUBERNETES_RELEASE="v1.30.1"
cd $DOWNLOAD_DIR
sudo curl -L --remote-name-all https://dl.k8s.io/release/${KUBERNETES_RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}

### setup kubelet service ###
RELEASE_VERSION="v0.16.9"
sudo mkdir -p /usr/lib/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /usr/lib/systemd/system/kubelet.service
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl enable --now kubelet

### setup kubernetes control plane ###
cat <<EOF | sudo tee /kubeadm-config.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  serviceSubnet: 100.68.0.0/16
  podSubnet: 100.64.0.0/14
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  bindPort: 6443
EOF

sudo kubeadm init --config=/kubeadm-config.yaml | sudo tee /kubeadm-init.log

export KUBECONFIG=/.kube/config

sudo mkdir -p /.kube
sudo cp /etc/kubernetes/admin.conf $KUBECONFIG

sudo chown -R root:root /.kube
sudo chmod -R 777 /.kube

echo -e "\nexport KUBECONFIG=/.kube/config" | sudo tee -a /root/.bashrc > /dev/null

# change for all required users
echo -e "\nexport KUBECONFIG=/.kube/config" | sudo tee -a /home/ubuntu/.bashrc > /dev/null

### untaint control plane scheduler eviction ###
kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-

### setup calico CNI ###
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
