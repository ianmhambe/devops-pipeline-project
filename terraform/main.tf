terraform {
  required_version = ">= 1.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "app_network" {
  name = "devops-network"
  driver = "bridge"
}

resource "docker_volume" "app_data" {
  name = "devops-app-data"
}

# This is a placeholder for local development
# In production, you would provision cloud resources here
resource "null_resource" "kind_cluster" {
  provisioner "local-exec" {
    command = "kind create cluster --config=../k8s/cilium/kind-config.yaml --name=devops-cluster"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name=devops-cluster"
  }
}
