variable "resource_group_name" {
  description = "The name of the new Resource Group"
  type        = string
}

variable "frontend_vm_prefix" {
  description = "The VM name prefix for the frontend servers"
  type        = string
}

variable "backend_vm_prefix" {
  description = "The VM name prefix for the backend servers"
  type        = string
}

variable "frontend_subnet" {
  description = "The name of the existing subnet for the frontend servers"
  type        = string
}

variable "backend_subnet" {
  description = "The name of the existing subnet for the backend servers"
  type        = string
}

variable "admin_username" {
  description = "The administrator's username"
  type        = string
}

variable "admin_password" {
  description = "The administrator's password"
  type        = string
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
}
