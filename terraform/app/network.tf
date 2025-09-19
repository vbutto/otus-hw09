resource "yandex_vpc_network" "todo_network" {
  name = "todo-network"
}

resource "yandex_vpc_subnet" "todo_subnet_a" {
  name           = "todo-subnet-a"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.todo_network.id
}

resource "yandex_vpc_subnet" "todo_subnet_b" {
  name           = "todo-subnet-b"
  v4_cidr_blocks = ["10.3.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.todo_network.id
}

resource "yandex_vpc_subnet" "todo_subnet_d" {
  name           = "todo-subnet-d"
  v4_cidr_blocks = ["10.4.0.0/16"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.todo_network.id
}
