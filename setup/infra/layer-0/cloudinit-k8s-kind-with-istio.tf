
data "cloudinit_config" "k8s_kind_with_istio" {
  base64_encode = false
  gzip          = false

  part {
    filename     = "setup.sh"
    content_type = "text/x-shellscript"
    content      = <<-EOT
      #!/bin/env bash

      ARCH="amd64"
      if [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi

      ### general dependencies ###
      sudo apt-get update
      sudo apt-get -qq install -y zip net-tools

      ### install kubectl ###
      curl https://dl.k8s.io/release/v1.26.3/bin/linux/$ARCH/kubectl -Lo ./kubectl
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl

      ### install kind ###
      curl https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-$ARCH -Lo ./kind
      chmod +x ./kind
      sudo mv ./kind /usr/local/bin/kind

      ### install helm ###
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh  --version v3.12.0
      rm get_helm.sh

      ### install docker ###
      sudo apt -qq install -y ca-certificates curl gnupg

      sudo install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg

      echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

      sudo apt -qq update
      sudo apt -qq install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

      cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
      {
        "ipv6": true,
        "fixed-cidr-v6": "2001:db8:1::/64"
      }
      EOF

      sudo groupadd docker
      sudo usermod -aG docker ubuntu

      sudo systemctl enable docker.service
      sudo systemctl enable containerd.service

      sudo mkdir -p /usr/local/lib/docker/cli-plugins
      sudo curl "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -Lo /usr/local/lib/docker/cli-plugins/docker-compose
      sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

      sudo systemctl restart docker.service

      ### disable rpcbind/sunrpc (port 111) ###
      sudo systemctl stop rpcbind.service
      sudo systemctl stop rpcbind.socket
      sudo systemctl disable rpcbind.service

      ### create node data folder ###
      NODE_DATA_PATH=/node-data
      sudo mkdir $NODE_DATA_PATH
      sudo chown -R root:root $NODE_DATA_PATH
      sudo chmod -R 777 $NODE_DATA_PATH

      ### create cluster ###
      CLUSTER_NAME=kind
      DATA_PATH=$NODE_DATA_PATH/kind-data
      PV_PATH=$NODE_DATA_PATH/kind-pv

      export KUBECONFIG=/.kube/config

      cat <<EOF | kind create cluster --wait 5m --config=-
      kind: Cluster
      apiVersion: kind.x-k8s.io/v1alpha4
      name: $CLUSTER_NAME
      nodes:
      - role: control-plane
        image: kindest/node:v1.27.3@sha256:3966ac761ae0136263ffdb6cfd4db23ef8a83cba8a463690e98317add2c9ba72
        kubeadmConfigPatches:
        - |
          kind: KubeletConfiguration
          apiVersion: kubelet.config.k8s.io/v1beta1
          imageGCHighThresholdPercent: 70
          imageGCLowThresholdPercent: 0
          imageMinimumGCAge: 30m
        extraPortMappings:
        - containerPort: 80
          hostPort: 80
          #listenAddress: "0.0.0.0"
        - containerPort: 443
          hostPort: 443
          #listenAddress: "0.0.0.0"
        extraMounts:
        - hostPath: $DATA_PATH
          containerPath: /mnt
        - hostPath: $PV_PATH
          containerPath: /var/local-path-provisioner
      networking:
        ipFamily: dual # ipv4 ipv6 dual
        apiServerPort: 6443
        apiServerAddress: "0.0.0.0"
      EOF

      sudo chown -R root:root /.kube
      sudo chmod -R 777 /.kube

      echo -e "\nexport KUBECONFIG=/.kube/config" | sudo tee -a /root/.bashrc > /dev/null
      echo -e "\nexport KUBECONFIG=/.kube/config" | sudo tee -a /home/ubuntu/.bashrc > /dev/null

      ### install istio ###
      export ISTIO_VERSION=1.21.2
      curl -L https://istio.io/downloadIstio | sh -
      mv ./istio-$ISTIO_VERSION ./istio
      sudo cp ./istio/bin/* /usr/local/bin
      EOT
  }
}
