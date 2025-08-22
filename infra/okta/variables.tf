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

variable "test_users" {
  description = "test users"
  type = map(object({
    email      = string
    first_name = string
    last_name  = string
    username   = string
  }))
  default = {
    volodic = {
      email      = "volodic@test.com"
      first_name = "Volodymyr"
      last_name  = "Nashkerskyi"
      username   = "volodic"
    }
    alice = {
      email      = "max@test.com"
      first_name = "Max"
      last_name  = "Dem"
      username   = "maxdem"
    }
    bob = {
      email      = "Taras@test.com"
      first_name = "Taras"
      last_name  = "Tarasovich"
      username   = "tardem"
    }
    charlie = {
      email      = "test@test.com"
      first_name = "test"
      last_name  = "test"
      username   = "test"
    }
    diana = {
      email      = "notest@test.com"
      first_name = "notest"
      last_name  = "notest"
      username   = "notest"
    }
  }
}

variable "default_password" {
  description = "Super powerful strong password "
  type        = string
  default     = "DoNotHack123"
  sensitive   = true
}