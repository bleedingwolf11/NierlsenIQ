provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "dev" {
  name     = "dev-rg"
  location = "East US" # Update the location based on your preference
}


resource "azurerm_virtual_network" "dev" {
  name                = "dev-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
}


resource "azurerm_subnet" "dev" {
  name                 = "dev-subnet"
  resource_group_name = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "dev" {
  name                = "dev-nsg"
  resource_group_name = azurerm_resource_group.dev.name
}


resource "azurerm_virtual_machine" "dev" {
  name                  = "dev-vm"
  resource_group_name   = azurerm_resource_group.dev.name
  location              = azurerm_resource_group.dev.location
  availability_set_id   = azurerm_virtual_network.dev.name
  network_interface_ids = [azurerm_network_interface.dev.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "dev-vm"
    admin_username = "adminuser"
    admin_password = "Password123!" 
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_network_interface" "dev" {
  name                = "dev-nic"
  resource_group_name = azurerm_resource_group.dev.name

  ip_configuration {
    name                          = "dev-nic-ipconfig"
    subnet_id                     = azurerm_subnet.dev.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate NSG with the NIC
resource "azurerm_network_interface_security_group_association" "dev" {
  network_interface_id      = azurerm_network_interface.dev.id
  network_security_group_id = azurerm_network_security_group.dev.id
}
