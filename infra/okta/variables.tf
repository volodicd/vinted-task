variable "okta_org" {
  type = string
  default = "integrator-1813408"
}

variable "api_key" {
  type = string
  sensitive = true
}

variable "app_name" {
  type = string
  default = "test-vinted"
}

