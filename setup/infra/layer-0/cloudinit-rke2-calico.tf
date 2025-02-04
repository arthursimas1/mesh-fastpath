data "cloudinit_config" "rke2_calico" {
  base64_encode = false
  gzip          = false

  part {
    filename     = "setup.sh"
    content_type = "text/x-shellscript"
    content      = <<-EOT
      #!/bin/env bash

      ### general dependencies ###
      apt-get update
      apt-get -qq install -y zip net-tools

      ### install Kubernetes using RKE2 ###
      mkdir -p /etc/rancher/rke2
      cat << EOF >  /etc/rancher/rke2/config.yaml
      cni:
        - calico
      disable:
        - rke2-canal
      EOF

      curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=v1.31.4+rke2r1 sh -
      systemctl enable rke2-server.service
      systemctl start rke2-server.service

      ### setup $KUBECONFIG environment variable ###
      export KUBECONFIG=/.kube/config

      mkdir -p /.kube

      chown -R root:root /.kube
      chmod -R 777 /.kube

      ln -s /etc/rancher/rke2/rke2.yaml /.kube/config

      # change for all required users
      echo -e "\nexport KUBECONFIG=/.kube/config" | tee -a /root/.bashrc > /dev/null
      echo -e "\nexport KUBECONFIG=/.kube/config" | tee -a /home/ubuntu/.bashrc > /dev/null

      ### update $PATH ###
      export PATH=$PATH:/var/lib/rancher/rke2/bin/
      echo -e "\nexport PATH=$PATH" | tee -a /root/.bashrc > /dev/null
      echo -e "\nexport PATH=$PATH" | tee -a /home/ubuntu/.bashrc > /dev/null

      ### install statexec ###
      curl -L "https://github.com/blackswifthosting/statexec/releases/download/0.8.0/statexec-linux-amd64" -o /usr/local/bin/statexec
      chmod +x /usr/local/bin/statexec

      ### install eztunnel ###
      curl -L "https://github.com/arthursimas1/eztunnel/releases/download/v0.1.1/eztunnel-linux-x86_64" -o /usr/local/bin/eztunnel
      chmod +x /usr/local/bin/eztunnel

      ### clone arthursimas1/eztunnel ###
      git clone https://github.com/arthursimas1/eztunnel.git /root/eztunnel

      EOT
  }
}
