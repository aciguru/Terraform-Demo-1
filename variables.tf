variable "tenant_name" {
  default = "aci-terraform-demo"
}

variable "bd1_subnet" {
  type    = "string"
  default = "99.99.99.1/24"
}

variable "aci_private_key" {
  default = "./admin.key"
}

variable "aci_cert_name" {
  default = "tf-test"
}

variable "provider_profile_dn" {
  default = "uni/vmmp-VMware"
}

variable "vmm_domain" {
  default = "ESX0-leaf102"
}

variable "vsphere_server" {
  default = "10.23.239.101"
}

variable "vsphere_user" {
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  default = "cisco123"
}

variable "vsphere_datacenter" {
  default = "ESX0"
}

variable "aci_vm1_address" {
  default = "99.99.99.10"
}

variable "aci_vm2_address" {
  default = "99.99.99.11"
}

variable "aci_vm3_address" {
  default = "99.99.99.12"
}

variable "aci_vm4_address" {
  default = "99.99.99.13"
}

variable "aci_vm1_name" {
  default = "demo-web"
}

variable "aci_vm2_name" {
  default = "demo-app"
}

variable "aci_vm3_name" {
  default = "demo-web-2"
}

variable "aci_vm4_name" {
  default = "demo-app-2"
}

variable "gateway" {
    default = "99.99.99.1"
}

variable "domain_name" {
  default = "cisco.com"
}

variable "vsphere_template" {
  default = "AppD-Ord-1_2_CLONE"
}

variable "folder" {
  default = "Apoorva"
}

variable "dns_list" {
  default = ["172.23.136.143","172.23.136.144"]
}

variable "dns_search" {
  default = ["cisco.com"]
}

variable "vsphere_host_name" {
  default = "10.23.239.30"
}

variable "vsphere_datastore" {
  default = "datastore1"
}
