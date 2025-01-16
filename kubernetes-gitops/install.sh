# Установка кластера Kubernetes удовлетваряющего условиям ДЗ в Yandex Cloud
#!/bin/bash

# Название клиента (передается как аргумент к скрипту)
folder_id=$1
auth_key=$2

# Проверка аргументов
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <folder_id> <auth_key_path>"
  exit 1
fi

# Проверка наличия auth_key
if [ ! -f "$auth_key" ]; then
  echo "Auth key file $auth_key not found."
  exit 1
fi

# Проверка наличия YC CLI
if ! command -v yc &> /dev/null; then
  echo "YC CLI not found. Please install and configure it."
  exit 1
fi

# Установка кластера Kubernetes в Yandex Cloud
cd terraform_YC_k8s || exit 1
echo "=== Установка кластера Kubernetes ==="
terraform apply -auto-approve || exit 1

# Регистррация кластер локально
echo "=== Регистррация кластер локально ==="
yc managed-kubernetes cluster get-credentials pars-bot --external

# Установка externaldns
cd .. || exit 1
echo "=== Установка externaldns ==="
helm install \
  --namespace externaldns \
  --create-namespace \
  --set config.folder_id="$folder_id" \
  --set-file config.auth.json="$auth_key" \
  externaldns ./externaldns/ || exit 1

# Установка Ingress-NGINX
echo "=== Установка Ingress-NGINX ==="
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
echo "Ingress-NGINX успешно установлен."