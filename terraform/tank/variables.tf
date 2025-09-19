variable "yc_folder" {
  type        = string
  description = "Yandex Cloud folder"
}

variable "sa_terraform_key_file" {
  description = "Path to service account (for terraform) key JSON file"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content (not path to file)"
  type        = string
  sensitive   = true
}

#variable "yc_token" {
#  type = string
#  description = "Yandex Cloud OAuth token"
#}

variable "user" {
  type        = string
  description = "$USER"
}

variable "overload_token" {
  type        = string
  description = "token for https://overload.yandex.net"
}
