variable "oktawave_access_token" {
  description = "OKTAWAVE access token"
  type        = string
}

provider "oktawave" {
  api_url      = "https://api.oktawave.com/beta"
  access_token = var.oktawave_access_token
}
