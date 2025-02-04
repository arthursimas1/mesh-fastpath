sudo dnf install -y snapd

sudo snap install lxd
sudo snap enable lxd
sudo snap start lxd

cat <<EOF | sudo lxd init --preseed
config:
  core.https_address: "[::]:9999"
  core.trust_password: password
  images.auto_update_interval: 0
networks:
EOF
