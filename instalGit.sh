#!/bin/bash

# Проверка наличия YC CLI
if ! command -v yc &> /dev/null; then
  echo "YC CLI not found. Please install and configure it."
  exit 1
fi

# Установка кластера Kubernetes в Yandex Cloud
cd terraform_YC_k8s || exit 1
echo "=== Установка кластера Kubernetes ==="
terraform apply -auto-approve || exit 1

# Регистрация кластер локально
echo "=== Регистррация кластер локально ==="
yc managed-kubernetes cluster get-credentials skyfly535 --external || exit 1

# Установка Helm чарта GitLab
cd .. || exit 1
echo "=== Установка Helm чарта GitLab ==="
helm install gitlab ./gitlab || exit 1

# Вывод root пароля для GitLab
echo "=== root пароля для GitLab ==="
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
