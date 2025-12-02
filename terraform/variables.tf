variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "devops-cluster"
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 3
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}
