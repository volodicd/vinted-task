output "client_id" {
  description = "OIDC Client ID"
  value       = okta_app_oauth.test_app.client_id
}

output "client_secret" {
  description = "OIDC Client Secret"
  value       = okta_app_oauth.test_app.client_secret
  sensitive   = true
}

output "issuer" {
  description = "OIDC Issuer URL"
  value       = "https://${var.okta_org}.okta.com/oauth2/default"
}

output "app_id" {
  description = "Okta App ID"
  value       = okta_app_oauth.test_app.id
}

