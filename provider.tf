variable "oktawave_access_token" {
  description = "OKTAWAVE access token"
  type        = string
}

provider "oktawave" {
  api_url = "https://pl1-api.oktawave.com/services"
  # notice:
  # endpoint for PL-2-KRK: https://pl2-api.oktawave.com/services
  access_token = var.oktawave_access_token
}
