terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "null" {}

variable "target_host" {
  description = "Target Ubuntu server IP"
  type        = string
  default     = "10.0.208.20"
}

variable "ssh_user" {
  description = "SSH kasutaja"
  type        = string
  default     = "kasutaja"
}

variable "ssh_private_key" {
  description = "SSH private key path (local path)"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

resource "null_resource" "ubuntu_setup" {
  # Trigger redeploy when files change
  triggers = {
    config_hash = filemd5("${path.module}/files/nginx.conf")
    html_hash   = filemd5("${path.module}/files/index.html")
  }

  connection {
    type        = "ssh"
    host        = var.target_host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "files/index.html"
    destination = "/tmp/index.html"
  }

  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/tmp/nginx-custom.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '=== Updating packages ==='",
      "sudo apt update -qq",
      "echo '=== Installing Nginx ==='",
      "sudo apt install -y nginx",
      "echo '=== Moving files into place ==='",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo mv /tmp/nginx-custom.conf /etc/nginx/sites-available/custom",
      "sudo ln -sf /etc/nginx/sites-available/custom /etc/nginx/sites-enabled/custom",
      "sudo nginx -t",
      "sudo systemctl reload nginx",
      "echo '=== Done ==='",
    ]
  }
}

output "connection_test" {
  value = "SSH connection successful to ${var.target_host}"
  depends_on = [null_resource.ubuntu_setup]
}
