# Terraform-Demo-1

## An Introduction to Terraform

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

(Source:[Terraform Homepage](https://www.terraform.io/intro/index.html))

## Main Mission
The main mission for this Terraform assignment is to migrate one VM from one EPG to another EPG.

###### The main.tf file
1. Create a Tenant
2. Create a VRF
3. Create a Bridge Domain
4. Create a Subnet
5. Create a VMM Domain
6. Create a Filter
7. Create a Filter Entry
8. Create a Contract
9. Create a Contract Subject and form a relationship to the filter
10. Create an Application Profile
11. Create EPGs (2 EPGs). Relate each EPG to a VMM Domain, BD create earlier and a Contract.

###### The vcenter.tf file
1. Create Datacenter
2. Create vSphere Network
3. Create Datastore
4. Create Host
5. Create Virtual Machine Template
6. Create Virtual Machine

###### The variables.tf file
1. Creation of all variables being referred throughout main.tf and vcenter.tf

###### The modules main.tf file
1. Link to first Tenant
2. Link to first VRF
3. Link to first Bridge Domain
4. Link to first Subnet
5. Create a VMM Domain
6. Create a Filter
7. Create a Filter Entry
8. Create a Contract
9. Create a Contract Subject and form a relationship to the filter
10. Create an Application Profile
11. Create EPGs (2 EPGs). Relate each EPG to a VMM Domain, BD create earlier and a Contract. 
