data "yandex_compute_image" "tank_image" {
  family = "yandextank"
}

data "yandex_vpc_network" "todo-network" {
  name = "todo-network"
}

data "yandex_vpc_subnet" "todo-subnet-a" {
  name = "todo-subnet-a"
}

data "yandex_lb_network_load_balancer" "todo_lb" {
  name = "todo-lb"
}


# Создание сервисного аккаунта для tank
resource "yandex_iam_service_account" "tank_sa" {
  name        = "tank-service-account"
  description = "Service account for Yandex Tank instance"
  folder_id   = var.yc_folder
}

# Назначение роли для доступа к compute ресурсам
resource "yandex_resourcemanager_folder_iam_member" "tank_sa_compute_viewer" {
  folder_id = var.yc_folder
  role      = "compute.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.tank_sa.id}"
}

# Назначение роли для мониторинга (если потребуется)
resource "yandex_resourcemanager_folder_iam_member" "tank_sa_monitoring_viewer" {
  folder_id = var.yc_folder
  role      = "monitoring.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.tank_sa.id}"
}

# Назначение роли для работы с load balancer
resource "yandex_resourcemanager_folder_iam_member" "tank_sa_lb_viewer" {
  folder_id = var.yc_folder
  role      = "load-balancer.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.tank_sa.id}"
}


resource "yandex_compute_instance" "tank" {
  name        = "todo-tank"
  folder_id   = var.yc_folder
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  # Привязываем сервисный аккаунт к инстансу
  service_account_id = yandex_iam_service_account.tank_sa.id

  resources {
    memory = 2
    cores  = 2
  }
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = data.yandex_compute_image.tank_image.id
      size     = 10
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.todo-subnet-a.id
    nat       = true
  }
  metadata = {
    user-data = templatefile("${path.module}/files/user-data.tpl", {
      user     = var.user
      ssh-keys = "${var.user}:${var.ssh_public_key}"
    })
  }

  // below are files that will be used by tank

  provisioner "file" {
    content = templatefile("${path.module}/files/load.yaml.tpl", {
      address = "${tolist(tolist(data.yandex_lb_network_load_balancer.todo_lb.listener).0.external_address_spec).0.address}"
      port    = "${tolist(data.yandex_lb_network_load_balancer.todo_lb.listener).0.port}"
    })
    destination = "/home/${var.user}/load.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      private_key = local.private_ssh_key
      host        = yandex_compute_instance.tank.network_interface.0.nat_ip_address
    }
  }

  provisioner "file" {
    source      = "files/ammo_add.txt"
    destination = "/home/${var.user}/ammo_add.txt"
    connection {
      type        = "ssh"
      user        = var.user
      private_key = local.private_ssh_key
      host        = yandex_compute_instance.tank.network_interface.0.nat_ip_address
    }
  }

  provisioner "file" {
    source      = "files/ammo_list.txt"
    destination = "/home/${var.user}/ammo_list.txt"
    connection {
      type        = "ssh"
      user        = var.user
      private_key = local.private_ssh_key
      host        = yandex_compute_instance.tank.network_interface.0.nat_ip_address
    }
  }

  provisioner "file" {
    source      = "files/monitoring.xml"
    destination = "/home/${var.user}/monitoring.xml"
    connection {
      type        = "ssh"
      user        = var.user
      private_key = local.private_ssh_key
      host        = yandex_compute_instance.tank.network_interface.0.nat_ip_address
    }
  }

  provisioner "file" {
    content     = var.overload_token
    destination = "/home/${var.user}/token.txt"
    connection {
      type        = "ssh"
      user        = var.user
      private_key = local.private_ssh_key
      host        = yandex_compute_instance.tank.network_interface.0.nat_ip_address
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.tank_sa_compute_viewer,
    yandex_resourcemanager_folder_iam_member.tank_sa_monitoring_viewer,
    yandex_resourcemanager_folder_iam_member.tank_sa_lb_viewer
  ]
}
