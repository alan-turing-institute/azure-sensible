# Prefix prepended to all Azure resources names (resource groups, virtual
# machines, etc.). You can set this to something easily identifiable, like the
# name of your project, to avoid name clashes and help locate resources.
# Default = "my"
# prefix = "project"

# Size of virtual machine to deploy
# (https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)
# Default = "Standard_B2s"
# vm_size = "Standard_DS3_v2"

# Data disk size in GB
# If > 0 a data disk will be created and attached to the virtual machine. The
# disk will have a single partition mounted at `/shared` and will be configured
# so all users have read/write access to the directory and all files created in
# it.
# Default = 0
# data_disk_size_gb = 100

# Azure region
# (https://azure.microsoft.com/en-us/global-infrastructure/geographies/) to
# deploy your resources to. This will have an impact on connection speed,
# available virtual machine sizes and cost.
# Default = "eastus"
# location = "uksouth"

# Username of the administrator account created to manage the virtual machine through Ansible.
# Default = "ansible_admin"
# admin_username = "ansible_admin"
