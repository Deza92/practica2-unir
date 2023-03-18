# Variable del Grupo de Recursos donde se "almacenarán" los recusos del mismo proyecto
variable "resource_group_name" {
  type = string
  description = "Resource group de Azure que se utiliza para el proyecto"
  default = "rg-createdbyTF"
}

# Variable de la localización
variable "location_name" {
  type = string
  description = "Región de Azure donde se creará la infraestructura"
  default = "UK West"
}

# Variable de la red del proyecto
variable "network_name" {
  type = string
  description = "Red de Azure de Azure que se utiliza para el proyecto"
  default = "vnet1"
}

# Variable de la subred del proyecto
variable "subnet_name" {
  type = string
  description = "Subred de Azure que se utiliza para el proyecto"
  default = "subnet1"
}

# Variable del nombre del admin de la vm
variable "ssh_user" {
  type = string
  default = "azureuser"
  description = "Usuario para hacer ssh"
}

# Variable del path de la public key de la vm
variable "path_public_key" {
  type = string
  description = "path de la clave pública"
  default = "~/.ssh/id_rsa.pub"
}

# Variable del nombre del registro de los contenedores
variable "acr_name" {
  type        = string
  description = "Nombre del registro de contenedores"
}

# Variable del nombre del cluster de kubernetes
variable "cluster_name" {
  type = string
  default = "clusterUnir"
  description = "Nombre del cluster kubernetes"
}

# Variable para indicar el número de agentes/workers
variable "agent_count" {
  default = 1
}