output "cluster_name" {
  description = "The name of the Kind cluster"
  value       = var.cluster_name
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.app_network.name
}
