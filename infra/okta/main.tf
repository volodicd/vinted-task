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
  "https://okta-test-app.lemonplant-b96601d2.westeurope.azurecontainerapps.io/auth/callback"]
  response_types = ["code"]
}


resource "okta_user" "volodic" {
  email      = "volodiaint@gmail.com"
  first_name = "Volodymyr"
  last_name  = "Nashkerskyi"
  login      = "volodiaint@gmail.com"
  password   = "SecurePassword123!"
}

resource "okta_app_user" "volodic_assignment" {
  app_id = okta_app_oauth.test_app.id
  user_id =okta_user.volodic.id
  username = "volodic"
}




