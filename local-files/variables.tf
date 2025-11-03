variable "environment" {
  description = "Keskkonna nimi (dev/test/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment peab olema: dev, test või prod"
  }
}

variable "app_name" {
  description = "Rakenduse nimi"
  type        = string
  default     = "myapp"
}

variable "port" {
  description = "Rakenduse port"
  type        = number
  default     = 8080

  validation {
    condition     = var.port > 1024 && var.port < 65535
    error_message = "Port peab olema vahemikus 1024-65535"
  }
}
