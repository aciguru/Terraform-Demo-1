provider "aci" {
  username = "admin"
  password = "Cisco!123"
  url      = "http://10.23.248.85/"
  insecure = true
  private_key = "./admin.key"
  cert_name   = "tf-test"
}

resource "aci_tenant" "terraform_ten" {
  name = "${var.tenant_name}"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "vrf1"
}

resource "aci_bridge_domain" "bd1" {
  tenant_dn          = "${aci_tenant.terraform_ten.id}"
  relation_fv_rs_ctx = "${aci_vrf.vrf1.name}"
  name               = "bd1"
}

resource "aci_subnet" "bd1_subnet" {
  bridge_domain_dn = "${aci_bridge_domain.bd1.id}"
  name             = "subnet"
  ip               = "${var.bd1_subnet}"
}         
         
data "aci_vmm_domain" "vds" {
  provider_profile_dn = "uni/vmmp-VMware"
  name                = "ESX0-leaf102"      
}     

resource "aci_filter" "allow_https" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "allow_https"
}
    
resource "aci_filter" "allow_icmp" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "allow_icmp"
}

resource "aci_filter_entry" "https" {
  name        = "https"
  filter_dn   = "${aci_filter.allow_https.id}"
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "https"
  d_to_port   = "https"
  stateful    = "yes"
}

resource "aci_filter_entry" "icmp" {
  name        = "icmp"
  filter_dn   = "${aci_filter.allow_icmp.id}"
  ether_t     = "ip"
  prot        = "icmp"
  stateful    = "yes"
}

resource "aci_contract" "contract_epg1_epg2" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "Web"
}

resource "aci_contract_subject" "Web_subject1" {
  contract_dn                  = "${aci_contract.contract_epg1_epg2.id}"
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = ["${aci_filter.allow_https.name}","${aci_filter.allow_icmp.name}"]
}

resource "aci_application_profile" "app1" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "app1"
}

resource "aci_application_epg" "epg1" {
  application_profile_dn = "${aci_application_profile.app1.id}"
  name                   = "epg1"
  relation_fv_rs_bd      = "${aci_bridge_domain.bd1.name}"
  relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"]
  relation_fv_rs_cons    = ["${aci_contract.contract_epg1_epg2.name}"]
}

resource "aci_application_epg" "epg2" {
  application_profile_dn = "${aci_application_profile.app1.id}"
  name                   = "epg2"
  relation_fv_rs_bd      = "${aci_bridge_domain.bd1.name}"
  relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"]
  relation_fv_rs_prov    = ["${aci_contract.contract_epg1_epg2.name}"]
}

module "prod_app2" {
  source = "modules/prod_app2"

#  tenant = "${aci_tenant.terraform_ten.name}"
#  vmm_domain_dn = "${aci_vmm_domain.vds.name}"
}

data "vsphere_datacenter" "dc2" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_network" "vm3_net" {
  depends_on       = ["module.prod_app2"]
  name          = "${format("%v|%v|%v", aci_tenant.terraform_ten.name, module.prod_app2.app2, module.prod_app2.epg3)}"
  datacenter_id = "${data.vsphere_datacenter.dc2.id}"
}

data "vsphere_network" "vm4_net" {
  depends_on       = ["module.prod_app2"]
  name          = "${format("%v|%v|%v", aci_tenant.terraform_ten.name, module.prod_app2.app2, module.prod_app2.epg4)}"   datacenter_id = "${data.vsphere_datacenter.dc2.id}"
}

data "vsphere_datastore" "ds2" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc2.id}"
}

# data "vsphere_compute_cluster" "cl2" {
#  name          = "${var.vsphere_compute_cluster}"
#  datacenter_id = "${data.vsphere_datacenter.dc2.id}"
#}

data "vsphere_host" "host2" {
  name          = "${var.vsphere_host_name}"
  datacenter_id = "${data.vsphere_datacenter.dc2.id}"
}

data "vsphere_virtual_machine" "template2" {
  name          = "${var.vsphere_template}"
  datacenter_id = "${data.vsphere_datacenter.dc2.id}"
}

resource "vsphere_virtual_machine" "aci_vm3" {
  depends_on       = ["module.prod_app2"]
  count            = 1
  name             = "${var.aci_vm3_name}"
#  resource_pool_id = "${data.vsphere_compute_cluster.cl2.resource_pool_id}"
  resource_pool_id = "${data.vsphere_host.host2.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.ds2.id}"

  num_cpus = 2
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.template2.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template2.scsi_type}"

  disk {
    label = "disk0"
    size  = "${data.vsphere_virtual_machine.template2.disks.0.size}"
    thin_provisioned = false
    eagerly_scrub = false
  }

  disk {
    unit_number = 1
    label       = "disk1"
    size        = 40
  }

  folder = "${var.folder}"
  network_interface {
    network_id   = "${data.vsphere_network.vm3_net.id}"
    # In order to migrate one EPG to another VM, you must change the network_id to the VM you want to migrate this EPG to.
    # network_id   = "${data.vsphere_network.vm1_net.id}"
    adapter_type = "${data.vsphere_virtual_machine.template2.network_interface_types[0]}"
  }

  clone {
    linked_clone  = "true"
    template_uuid = "${data.vsphere_virtual_machine.template2.id}"

    customize {
      linux_options {
        host_name = "${var.aci_vm3_name}"
        domain    = "${var.domain_name}"
      }

      network_interface {
        ipv4_address = "${var.aci_vm3_address}"
        ipv4_netmask = "24"
      }

      ipv4_gateway    = "${var.gateway}"
      dns_server_list = "${var.dns_list}"
      dns_suffix_list = "${var.dns_search}"
    }
  }
}

resource "vsphere_virtual_machine" "aci_vm4" {
  depends_on       = ["module.prod_app2"]
  count            = 1
  name             = "${var.aci_vm4_name}"
#  resource_pool_id = "${data.vsphere_compute_cluster.cl2.resource_pool_id}"
  resource_pool_id = "${data.vsphere_host.host2.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.ds2.id}"

  num_cpus = 2
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.template2.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template2.scsi_type}"

  disk {
    label = "disk0"
    size  = "${data.vsphere_virtual_machine.template2.disks.0.size}"
    thin_provisioned = false
    eagerly_scrub = false
  }

  disk {
    unit_number = 1
    label       = "disk1"
    size        = 40
  }

  folder = "${var.folder}"

  network_interface {
    network_id   = "${data.vsphere_network.vm4_net.id}"
    adapter_type = "${data.vsphere_virtual_machine.template2.network_interface_types[0]}"
  }

  clone {
    linked_clone  = "true"
    template_uuid = "${data.vsphere_virtual_machine.template2.id}"
     customize {
      linux_options {
        host_name = "${var.aci_vm4_name}"
        domain    = "${var.domain_name}"
      }

      network_interface {
        ipv4_address = "${var.aci_vm4_address}"
        ipv4_netmask = "24"
      }

      ipv4_gateway    = "${var.gateway}"
      dns_server_list = "${var.dns_list}"
      dns_suffix_list = "${var.dns_search}"
    }
  }
}
