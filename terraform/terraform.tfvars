# Prefix for all Azure resource names
#
# You can set this to something easily identifiable, like the name of your
# project, to avoid name clashes and help locate resources.
#
# Default = "my"
#
# Example:
# prefix = "project"


# Size of virtual machine to deploy
#
# You can find details of available sizes here:
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
#
# Default = "Standard_B2s"
#
# Example:
# vm_size = "Standard_D8s_v4"


# Type of storage to use
#
# You can find details of the storage types here:
# https://docs.microsoft.com/en-us/azure/virtual-machines/disks-types?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json
# The valid options are Standard_LRS, StandardSSD_LRS, and Premium_LRS
#
# Default = "StandardSSD_LRS"
#
# Example
# storage_type = "Premium_LRS"


# Data disk size in GB
#
# If > 0 a data disk will be created and attached to the virtual machine. The
# disk will have a single partition mounted at `/shared` and will be configured
# so all users have read/write access to the directory and all files created in
# it.
#
# Default = 0
#
# Example
# data_disk_size_gb = 100


# Azure region to deploy resources to
#
# You can see the Azure regions here:
# https://azure.microsoft.com/en-us/global-infrastructure/geographies/ .  This
# will have an impact on connection speed, available virtual machine sizes and
# cost.
#
# Default = "eastus"
#
# Example
# location = "uksouth"


# Administrator account username
#
# This account will be used to manage the virtual machine through Ansible.
#
# Default = "ansible_admin"
#
# Example
# admin_username = "sam_spade"
