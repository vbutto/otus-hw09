# Роли сервисного аккаунта для terraform
# container-registry.viewer - просмотр образов в реестре
# iam.serviceAccountAdmin - создание сервисных аккаунтов
# vpc.privateAdmin - создание и управление VPC
# vpc.publicAdmin - создание и управление VPC
# vpc.user - использование VPC
# compute.admin - создание и управление ВМ
# load-balancer.admin - создание и управление балансировщиками


locals {
  registry_name = "todo-registry"
}

provider "yandex" {
  endpoint                 = "api.cloud.yandex.net:443"
  service_account_key_file = var.sa_key_file
  folder_id                = var.yc_folder
  zone                     = "ru-central1-c"

}
