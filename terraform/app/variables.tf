variable "yc_folder" {
  type        = string
  description = "Yandex Cloud folder"
}

#variable "yc_token" {
#  type = string
#  description = "Yandex Cloud OAuth token"
#}

variable "user" {
  type        = string
  description = "$USER"
}

variable "sa_key_file" {
  description = "Path to service account key JSON file"
  type        = string
}

# ============================================================================
# Настройки доступа
# ============================================================================

variable "ssh_public_key" {
  description = "SSH public key content (not path to file)"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Your IP address in CIDR format for SSH access (e.g., 1.2.3.4/32). Leave empty to disable SSH"
  type        = string
  default     = ""
}
