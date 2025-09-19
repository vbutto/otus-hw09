terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }

    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
