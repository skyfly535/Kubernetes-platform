#!/bin/bash

# Скрипт для установки ArgoCD, настройки проекта и создания секретов

set -e  # Прекращает выполнение при любой ошибке

# Проверка, что переданы все необходимые аргументы
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <git_user> <git_token>"
  exit 1
fi

git_user=$1
git_token=$2

# Установка Helm чарта ArgoCD
echo "=== Установка ArgoCD ==="
cd argocd
kubectl apply -f nsargocd.yaml
helmfile apply
cd ..
echo "ArgoCD успешно установлен."

# Создание проекта Otus в ArgoCD
echo "=== Создание проекта Otus в ArgoCD ==="
kubectl apply -f appproject.yaml
echo "Проект Otus успешно создан."

# Создание секрета для доступа к репозиторию GitLab
echo "=== Создание секрета для доступа к репозиторию GitLab ==="
cat <<EOF > repo-parsbot-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-parsbot
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  name: pars-bot
  url: https://gitlab.otus-skyfly.ru/skyfly534/pars-bot.git
  username: $git_user
  password: "$git_token"
EOF

kubectl apply -f repo-parsbot-secret.yaml
rm -f repo-parsbot-secret.yaml  # Удаление временного файла
echo "Секрет repo-parsbot успешно создан."
echo "=== Создание секретов Docker Registry ==="

# Создает namespace parsbot, если его еще нет 
kubectl create namespace parsbot || true  

# Создание Docker Registry секрета
echo "=== Создание Docker Registry секрета GitLab ==="
kubectl create secret docker-registry regcred \
  --docker-server=registry.otus-skyfly.ru \
  --docker-username=gitlab+deploy-token-1 \
  --docker-password=$git_token \
  --docker-email=otus2024@mail.ru \
  --namespace=parsbot
echo "Секреты regcred успешно созданы."

# Запуск приложения в ArgoCD
echo "=== Запуск приложения в ArgoCD ==="
kubectl apply -f parsbot-application.yaml
echo "Приложение успешно запущено."

# Вывод пароля Admin ArgoCD для входа ==="
echo "=== Пароль Admin ArgoCD для входа ==="
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

echo "=== Установка завершена успешно ==="

