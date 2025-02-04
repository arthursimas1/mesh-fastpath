terraform {
  required_providers {
    /*cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.33.0"
    }*/
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.4"
    }
    #random = {
    #  source  = "hashicorp/random"
    #  version = "3.6.1"
    #}
    /*kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }*/
    lxd = {
      source = "terraform-lxd/lxd"
      version = "2.4.0"
    }
    /*xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = "0.29.0"
    }*/
  }
  required_version = "~> 1.10.3"
}
