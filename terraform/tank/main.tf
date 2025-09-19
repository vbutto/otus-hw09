locals {
  public_ssh_key  = file("C:\\Users\\Vyacheslav\\.ssh\\id_ed25519.pub")
  private_ssh_key = file("C:\\Users\\Vyacheslav\\.ssh\\id_ed25519")
}

provider "yandex" {
  endpoint                 = "api.cloud.yandex.net:443"
  service_account_key_file = var.sa_terraform_key_file
  folder_id                = var.yc_folder
  zone                     = "ru-central1-a"
}
