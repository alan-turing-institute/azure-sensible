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


# Addresses permitted to connect by SSH
#
# Each item of this list can be an IP address, or IP address range in CIDR
# notation. If (and only if) the list is one element long, you can also use
# Azure tags such as "VirtualNetwork", "Internet", or "*" (to match any IP).
#
# Default = ["*"]
#
# Example
# ssh_addresses = [
#   "10.0.0.0/16",
#   "104.20.26.62"
# ]


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


# Virtual machine image
#
# This is an object defining which Linux virtual machine image to use. Each
# image is defined by four strings, publisher, offer, sku and version. You can
# find advice on searching through the available images here
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
#
# The default image is Ubuntu 20.04, and the example below will deploy an Ubuntu
# data science virtual machine
# https://azure.microsoft.com/en-us/services/virtual-machines/data-science-virtual-machines/
#
# Default = {
#   publisher = "Canonical"
#   offer     = "0001-com-ubuntu-server-focal"
#   sku       = "20_04-lts"
#   version   = "latest"
# }
#
# Example (An Ubuntu 18.04 data science virtual machine):
# vm_image = {
#   publisher = "microsoft-dsvm"
#   offer     = "ubuntu-1804"
#   sku       = "1804"
#   version   = "latest"
# }


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
