locals {
  dbuser     = yandex_mdb_postgresql_user.app.name
  dbpassword = yandex_mdb_postgresql_user.app.password
  dbhosts    = yandex_mdb_postgresql_cluster.todo_postgresql.host.*.fqdn
  dbname     = yandex_mdb_postgresql_database.todo_db.name
}

resource "yandex_mdb_postgresql_cluster" "todo_postgresql" {
  name        = "todo-postgresql"
  folder_id   = var.yc_folder
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.todo_network.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.small"
      disk_type_id       = "network-ssd"
      disk_size          = 20
    }
  }

  host {
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.todo_subnet_a.id
    assign_public_ip = true
  }
  host {
    zone             = "ru-central1-d"
    subnet_id        = yandex_vpc_subnet.todo_subnet_d.id
    assign_public_ip = true
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "yandex_mdb_postgresql_user" "app" {
  cluster_id = yandex_mdb_postgresql_cluster.todo_postgresql.id
  name       = "app"
  password   = random_password.db_password.result
}

resource "yandex_mdb_postgresql_database" "todo_db" {
  cluster_id = yandex_mdb_postgresql_cluster.todo_postgresql.id
  name       = "db"
  owner      = yandex_mdb_postgresql_user.app.name
}
