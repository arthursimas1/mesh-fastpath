/*provider "cloudflare" {
  api_token = var.cf_api_token
}*/

provider "cloudinit" {}

#provider "random" {}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  remote {
    name     = var.lxd_name
    address  = var.lxd_address
    password = var.lxd_password
    default  = true
  }
}

/*provider "xenorchestra" {
  url      = var.xoa_endpoint
  //username = var.xoa_username
  //password = var.xoa_password
  token = var.xoa_token

  insecure = true
}*/

/*provider "kubernetes" {
  host                   = var.kubernetes_endpoint
  token                  = var.kubernetes_token
  tls_server_name        = "kubernetes"
  cluster_ca_certificate = var.kubernetes_cluster_ca_cert
  ignore_annotations = [
    "kubectl\\.kubernetes\\.io\\/restartedAt",
  ]
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes_endpoint
    token                  = var.kubernetes_token
    tls_server_name        = "kubernetes"
    cluster_ca_certificate = var.kubernetes_cluster_ca_cert
  }
}*/
