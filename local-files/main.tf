terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "local" {}

resource "local_file" "greeting" {
  filename = "${path.module}/output/hello.txt"
  content  = "Tere, Terraform!\nSee fail on loodud IaC-ga.\n"
  file_permission = "0644"
}

resource "local_file" "config" {
  filename = "${path.module}/output/${var.app_name}.conf"
  content  = <<-EOT
    # ${var.app_name} Configuration
    # Environment: ${var.environment}

    server {
      port = ${var.port}
      host = "localhost"
      env  = "${var.environment}"
    }
  EOT
  file_permission = "0644"
}
