variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "CitizenServices-RG-Terraform"
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "East US"
}

variable "project_prefix" {
  description = "A prefix used for naming resources to ensure uniqueness."
  type        = string
  default     = "citizensvcsaamani"
}

variable "function_app_name" {
  description = "The globally unique name of the Function App."
  type        = string
  default     = "citizenservices-api-aamani-tf"
}
