output "tank_instance_id" {
  value = yandex_compute_instance.tank.id
}

output "tank_address" {
  value = yandex_compute_instance.tank.network_interface.0.nat_ip_address
}

output "tank_service_account_id" {
  value       = yandex_iam_service_account.tank_sa.id
  description = "ID of the tank service account"
}
