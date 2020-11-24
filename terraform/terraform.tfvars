# Prefix prepended to all Azure resources names (resource groups, virtual
# machines, etc.). You can set this to something easily identifiable, like the
# name of your project, to avoid name clashes and help locate resources.
# Default = "my"
# prefix = "project"

# Size of virtual machine to deploy
# (https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)
# Default = "Standard_B2s"
# vm_size = "Standard_DS3_v2"

# Azure region
# (https://azure.microsoft.com/en-us/global-infrastructure/geographies/) to
# deploy your resources to. This will have an impact on connection speed,
# available vm sizes and cost.
# Default = "eastus"
# location = "uksouth"

# Username of the administrator account created to manage the virtual machine through Ansible.
# Default = "ansible_admin"
# admin_username = "ansible_admin"
