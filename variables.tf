variable "oktawave_access_token" {
  description = "Access token"
  default       = "insert_token_here"
  type          = string
}

variable "authorization_method_id" {
  description = "Ssh key (1398) or password (1399) ID"
  default     = 1398
}