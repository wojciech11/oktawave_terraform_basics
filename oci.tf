resource "oktawave_oci" "my_oci" {

# NAME:
instance_name="TERRAFORM_OCI"

# OCI AUTH METOD:
authorization_method_id=var.authorization_method_id

ssh_keys_ids = [oktawave_sshKey.my_key.id]

# OVS (STORAGE) PARAMETERS:
# disk class (tier)
disk_class=48

# disk size
init_disk_size=5

# IP ADDRESS:
# Available values: id of ip address that you want to set as default
# Comment: Replace default ip address that would be created as part of instance setup
# If you comment this field, ip address will be computed & obtained by default
# ip_address_id=id

# SUBREGION ID: 
subregion_id=7
# INSTANCE CLASS & OS TYPE:
type_id = 1268
template_id =1021
# INSTANCES COUNT:
instances_count = 1
# FREEMIUM PLAN (IF AVAILABLE):
isfreemium=false

}