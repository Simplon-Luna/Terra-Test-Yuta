# Resource group name creation
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Resource group creation
resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "Tf_vnet_g4"
  address_space       = ["10.0.0.0/21"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create subnet 1
# resource "azurerm_subnet" "myterraformsubnetpterodactil" {
#   name                 = "${var.prefix}_subnet_pterodactil"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
#   address_prefixes     = ["10.0.4.0/24"]
# }

# create subnet Wings
resource "azurerm_subnet" "myterraformsubnepterodactil" {
  name                 = "${var.prefix}_subnet_wings"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.6.0/24"]
}

# create public ip Panel
resource "azurerm_public_ip" "mypublicip" {
  name                 = "${var.prefix}_public_ip_Panel"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  # virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  allocation_method    = "Static"
}

# create public ip Load Balancer - Front
resource "azurerm_public_ip" "mypublicip2" {
  name                 = "${var.prefix}_public_ip_LoadB_Front"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  # virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  allocation_method    = "Static"
  sku                  = "Standard"
}

# Create Network Security Group and Rules
resource "azurerm_network_security_group" "myterraformsecuritygroup" {
  name                = "${var.prefix}_security_group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface public Panel
resource "azurerm_network_interface" "myterraformnetworkinterface" {
  name                = "${var.prefix}_network_interface1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config_Panel_Pub"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublicip.id
  }
}

# Create network interface Private Panel
resource "azurerm_network_interface" "myterraformnetworkinterfacePanel" {
  name                = "${var.prefix}_network_interface_Panel_Priv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config_Panel"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create network interface Wings
resource "azurerm_network_interface" "myterraformnetworkinterfaceWings" {
  name                = "${var.prefix}_network_interface_Wings"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config_Wings"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create network interface LoadB
resource "azurerm_network_interface" "myterraformnetworkinterfaceLoadB" {
  name                = "${var.prefix}_network_interface_LoadB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config4"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "terraformconnect" {
  network_interface_id      = azurerm_network_interface.myterraformnetworkinterface.id
  network_security_group_id = azurerm_network_security_group.myterraformsecuritygroup.id
}

# Create Panel VM
resource "azurerm_linux_virtual_machine" "myterraformvmpanel" {
  name                  = "${var.prefix}_vmPanel"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnetworkinterface.id, azurerm_network_interface.myterraformnetworkinterfacePanel.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk2"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvmPanel"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = "123456Azerty$."
}

# Create Wings VM
resource "azurerm_linux_virtual_machine" "myterraformwings" {
  name                  = "${var.prefix}_vmWings"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnetworkinterfaceWings.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvmWings"
  admin_username                  = "wingsuser"
  disable_password_authentication = false
  admin_password                  = "123456ytreza$."
}

# Creation of Redis
# /!\ NOTE: the Name used for Redis needs to be globally unique /!\
resource "azurerm_redis_cache" "redis_azure" {
  name                = "${var.prefix}redis"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}
# Creation of MariaDB
resource "azurerm_mariadb_server" "mariadbterraform" {
  name                = "${var.prefix}mariadb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "mariadbadmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "10.2"

  auto_grow_enabled             = true
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  ssl_enforcement_enabled       = true
}

# Creation of Load Balancer
resource "azurerm_lb" "load-balance" {
  name                = "${var.prefix}_load-blance"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}ip_public_LoadB"
    public_ip_address_id = azurerm_public_ip.mypublicip2.id
  }
}

# Creation of LoadB Backend Pool Panel
resource "azurerm_lb_backend_address_pool" "backendpoolpanel" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.load-balance.id
  name                = "BackEndAddressPool"
}

# Creation of Backend Pool's Private IP address
resource "azurerm_lb_backend_address_pool_address" "backendpollAdresse" {
  name                    = "${var.prefix}BackendPool"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpoolpanel.id
  virtual_network_id      = azurerm_virtual_network.myterraformnetwork.id
  ip_address              = azurerm_network_interface.myterraformnetworkinterfaceLoadB.private_ip_address
}

# Config of LoadB Outbound rules
resource "azurerm_lb_outbound_rule" "outbound_rule_panel" {
  name                    = "${var.prefix}OutboundRule"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id         = azurerm_lb.load-balance.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpoolpanel.id

  frontend_ip_configuration {
    name = "${var.prefix}_public_ip_LoadB_Front"
  }
}