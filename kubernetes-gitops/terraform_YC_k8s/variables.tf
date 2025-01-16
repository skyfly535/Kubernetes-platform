variable "service_account_key_file" {
  description = "Path to service account key file"
}

variable "cloud_id" {
  description = "Cloud"
}

variable "zone" {
  description = "Zone"
  default     = "ru-central1-a"
}

variable "folder_id" {
  description = "Folder"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "cluster_name" {
  description = "Name of cluster"
}

variable "k8s_version" {
  description = "Kubernetes version"
}

variable "service_account_id" {
  description = "Service account"
}

variable "network_id" {
  description = "Network"
}

variable "subnet_id" {
  description = "Subnet"
}

variable "node_cpu_count" {
  description = "Node CPU count"
}

variable "node_memory_size" {
  description = "Node memory size"
}

variable "node_disk_size" {
  description = "Node disk size"
}

variable "infra_nodes_count" {
  description = "Nodes count"
}

variable "workload_nodes_count" {
  description = "Nodes count"
}