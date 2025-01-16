resource "yandex_kubernetes_cluster" "yc_cluster" {
  name                    = var.cluster_name

  master {
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }
    version               = var.k8s_version
    public_ip             = true
  }

  network_id              = var.network_id

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"
}


resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = yandex_kubernetes_cluster.yc_cluster.id

  version     = var.k8s_version
  count       = var.nodes_count

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = [var.subnet_id]
    }

    resources {
      memory = var.node_memory_size
      cores  = var.node_cpu_count
    }

    boot_disk {
      type = "network-ssd"
      size = var.node_disk_size
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

}
