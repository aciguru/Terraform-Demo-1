resource "aci_tenant" "terraform_ten" {
  name = "aci-terraform-demo"
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
  name             = "Subnet"
  ip               = "99.99.99.1/24"
}

data "aci_vmm_domain" "vds" {
  provider_profile_dn = "uni/vmmp-VMware"
  name                = "ESX0-leaf102"
}

resource "aci_application_profile" "app2" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "prod_app2"
}

resource "aci_application_epg" "epg3" {
  application_profile_dn = "${aci_application_profile.app2.id}"
  name                   = "epg3"
  relation_fv_rs_bd      = "${aci_bridge_domain.bd1.name}"
  relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"]
  relation_fv_rs_cons    = ["${aci_contract.contract_epg3_epg4.name}"]
}

resource "aci_application_epg" "epg4" {
  application_profile_dn = "${aci_application_profile.app2.id}"
  name                   = "epg4"
  relation_fv_rs_bd      = "${aci_bridge_domain.bd1.name}"
  relation_fv_rs_dom_att = ["${data.aci_vmm_domain.vds.id}"]
  relation_fv_rs_prov    = ["${aci_contract.contract_epg3_epg4.name}"]
}

resource "aci_contract" "contract_epg3_epg4" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "Web_app2"
}

resource "aci_contract_subject" "Web_subject1" {
  contract_dn                  = "${aci_contract.contract_epg3_epg4.id}"
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = ["${aci_filter.allow_https2.name}"]
}

resource "aci_filter" "allow_https2" {
  tenant_dn = "${aci_tenant.terraform_ten.id}"
  name      = "allow_https2"
}

resource "aci_filter_entry" "https2" {
  name        = "https2"
  filter_dn   = "${aci_filter.allow_https2.id}"
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "https"
  d_to_port   = "https"
  stateful    = "yes"
}

output "app2" {
  value = "${aci_application_profile.app2.name}"
}

output "epg3" {
  value = "${aci_application_epg.epg3.name}"
}

output "epg4" {
  value = "${aci_application_epg.epg4.name}"
}
