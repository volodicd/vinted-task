terraform {
  required_version = ">= 1.5.0"
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 4.8"
    }
  }
}


provider "okta" {
  org_name = var.okta_org
  base_url = "okta.com"
  api_token = var.api_key
}

resource "okta_app_oauth" "test_app" {
  label         = var.app_name
  type          = "web"
  grant_types   = ["authorization_code"]
  redirect_uris = ["http://localhost:8080/auth/callback",
  "https://oktatestacr-app.gentlegrass-265232fc.westeurope.azurecontainerapps.io/auth/callback"]
  response_types = ["code"]
  status = "ACTIVE"
}


resource "okta_user" "test_users" {
  for_each = var.test_users
  email = each.value.email
  first_name = each.value.first_name
  last_name = each.value.last_name
  login = each.value.email
  password = var.default_password
  status     = "ACTIVE"
}

resource "okta_app_user" "assignments" {
  for_each = var.test_users
  app_id = okta_app_oauth.test_app.id
  user_id = okta_user.test_users[each.key].id
  username = each.value.username
}




