/*
###################################################
# Environment Specs
###################################################
variable "location" {
  type        = string
  description = "The location of the resource group"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dev"
}
variable "rg_name" {
    type = "string"
    description = "The name of the resource group"
    default = "XXXXX"
}
###################################################
# Key Vault Components
###################################################

variable "key_vault_name" {
  type        = string
  description = "the name of the main key vault"
  default     = "mykeyvault"
}
variable "key_vault_resource_id" {
  type        = string
  description = "the resource id of the main key vault"
  default     = "XXXXX"
}
variable "admin_pw_name" {
  type        = string
  description = "the admin password of the vm"
  default     = "admin-pw"
}

# -------------------- MAIN.TF--------------------------------
terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  version         = "1.29.0"
  subscription_id = var.azurerm_provider_subscription_id
  client_id       = var.azurerm_provider_client_id
  client_secret   = var.azurerm_provider_client_secret
  tenant_id       = var.azurerm_provider_tenant_id
}

locals {
  environment = trimspace(var.environment)
}
locals {
  vm = {
    computer_name = "vm1"
    user_name     = "admin1234"
  }
}
locals {
  scriptWorkingDir = "/home/${local.vm.user_name}/"
}


data "azurerm_key_vault_secret" "main" {
  name         = var.admin_pw_name
  key_vault_id = var.key_vault_resource_id
}


data "azurerm_resource_group" "main" {
  name     = var.rg_name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"

  security_rule {
    name                       = "AllowSSHIn"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = local.environment
  }

  depends_on = [data.azurerm_resource_group.main]
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.environment}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"


  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
    security_group = "${azurerm_network_security_group.nsg.id}"
  }

  depends_on = [data.azurerm_resource_group.main, azurerm_network_security_group.nsg]

}

data "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  virtual_network_name = "${local.environment}-network"
  resource_group_name  = "${data.azurerm_resource_group.main.name}"
}

resource "azurerm_public_ip" "vm" {
  name                = "mypip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  depends_on          = [data.azurerm_resource_group.main]
}

resource "azurerm_network_interface" "vm" {
  name                = "${local.environment}-nic"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vm.id}"
  }

  depends_on = [data.azurerm_resource_group.main, azurerm_virtual_network.main, azurerm_public_ip.vm]
}

resource "azurerm_virtual_machine" "vm" {

  name                  = "${local.environment}-vm"
  location              = "${data.azurerm_resource_group.main.location}"
  resource_group_name   = "${data.azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.vm.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = local.vm.computer_name
    admin_username = local.vm.user_name
    admin_password = data.azurerm_key_vault_secret.main.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = local.environment
  }

  depends_on = [data.azurerm_resource_group.main, azurerm_virtual_network.main]

}

data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/test.sh"
  output_path = "${path.module}/test.zip"
}

resource "null_resource" remoteExecProvisioner {

  triggers = {
    src_hash = "${data.archive_file.init.output_sha}"
  }

  provisioner "file" {
    source      = "./test.sh"
    destination = "${local.scriptWorkingDir}/test.sh"
  }

  connection {
    host     = azurerm_public_ip.vm.ip_address
    type     = "ssh"
    user     = local.vm.user_name
    password = data.azurerm_key_vault_secret.main.value
    agent    = "false"
  }
  depends_on = [azurerm_virtual_machine.vm, azurerm_network_security_group.nsg]
}

resource "azurerm_virtual_machine_extension" "main" {

  name                 = "hostname"
  location             = "${data.azurerm_resource_group.main.location}"
  resource_group_name  = "${data.azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
      "commandToExecute": "chmod +x ${local.scriptWorkingDir}/test.sh; sudo apt-get install dos2unix; dos2unix ${local.scriptWorkingDir}/test.sh; /bin/bash ${local.scriptWorkingDir}/test.sh ${data.archive_file.init.output_sha} >> ${local.scriptWorkingDir}/helloworld.log"
  }
  SETTINGS

  tags = {
    environment = local.environment
  }

  depends_on = [azurerm_virtual_machine.vm, azurerm_network_security_group.nsg, null_resource.remoteExecProvisioner]
}
# -------------------- OUTPUTS.TF--------------------------------
output "vmEndpoint" {
  value = azurerm_public_ip.vm.ip_address
}
output "username" {
  value = local.vm.user_name
}
output "password" {
  value = data.azurerm_key_vault_secret.main.value
}
*/