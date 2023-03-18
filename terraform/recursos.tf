# Recursos de la infraestructura que se desplegarán en Azure

### SECTION RESOURCE GROUP
# Se indica el grupo de recursos de azure
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

### SECTION VIRTUAL NETWORK
# Se especifican las características la red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Caracteristicas de la subnet de la red virtual
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Características para la IP publica
resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip"
  location            = var.location_name
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Características puertos 22, 443, 8080
resource "azurerm_network_security_group" "ansg" {
  name                = "ports"
  location            = var.location_name
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ports_ansg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["22","443", "8080"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

### SECTION VIRTUAL MACHINE
# Caracteristicas de la VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1Unir"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = var.user
  admin_password      = var.pass_user
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
# Caracteristicas de la NIC
resource "azurerm_network_interface" "nic" {
  name                = "vnic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Características de la asociacion de las reglas del puerto 22, 443, 8080
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.ansg.id
}


### SECTION DOCKER IMAGE CONTAINER
# Caracteristicas del registro de contenedores donde se almacenarán imágenes docker
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location_name
  sku                 = "Standard"
  admin_enabled       = true
}


### SECTION CLUSTER KUBERNETES
# Características del cluster de Kubernetes en Azure
resource "azurerm_kubernetes_cluster" "aks" {
  location            = var.location_name
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "default"
    node_count          = var.agent_count
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }
}