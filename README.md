 **Проектная работа: "Инфраструктурная Managed k8s платформа для онлайн-магазина"**

Ссылки: 
[приложение:](https://bokhanych-demoshop.ust.inc)
[grafana:](http://65.109.41.169) # admin/prom-operator

**Реализовано:**
 - [x] Создание кластера [Hetzner Cloud with Kubespray, HCLOUD Controller Manager and Storage Driver]
 - [x] Присвоение меток нодам и запуск приложения только на нодах "worker"
 - [x] Изменение пространства имен приложения [onlineboutique]
 - [x] Изменение количества реплик важных сервисов приложения [cartservice,frontend,productcatalogservice]
 - [x] Мониторинг кластера [datasource, dashboards, telegram alerts]
 - [x] Логирование кластера [grafana/loki,grafana/promtail]
 - [x] CI\CD [Github Actions + ArgoCD]
 - [x] Установка Minio object storage system

## Создание кластера: 
```
# MANUAL: Install Kubernetes in Hetzner Cloud with Terraform, Kubespray, HCLOUD Controller Manager and Storage Driver: https://www.youtube.com/watch?v=S424jkxtEf0
mkdir kube-setup && cd kube-setup
git clone https://github.com/kubernetes-sigs/kubespray.git
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements.txt
cd ..
mkdir -p clusters/eu-central
declare -a IPS=(10.98.0.2 10.98.0.3 10.98.0.4 10.98.0.5 10.98.0.6)
CONFIG_FILE=clusters/eu-central/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}
pip install ruamel.yaml
vi clusters/eu-central/hosts.yaml
vi clusters/eu-central/cluster-config.yaml
cd kubespray
vi inventory/sample/group_vars/k8s_cluster/addons.yml
ansible-playbook -i ../clusters/eu-central/hosts.yaml -e @../clusters/eu-central/cluster-config.yaml --become --become-user=root cluster.yml
```

Присвоение меток нодам:
```
kubectl taint nodes <node_name> node-role.kubernetes.io/control-plane:NoSchedule
kubectl label nodes <node_name> node-role.kubernetes.io/worker=worker

NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    control-plane   12d   v1.31.1
node2   Ready    control-plane   12d   v1.31.1
node3   Ready    worker          12d   v1.31.1
node4   Ready    worker          12d   v1.31.1
node5   Ready    worker          12d   v1.31.1
```
Запуск приложения только на нодах "worker":
```
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/worker
                operator: In
                values:
                - worker
```

Изменение пространства имен приложения:
```
metadata:
  namespace: onlineboutique
```

Изменение количества реплик:
```
spec:
  replicas: 2
```

## CD:
Для установки приложения используем ArgoCD. Мониторит изменения в папке ***application***.
```
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Change the argocd-server service type to LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
pGgVXkh1b6snGyET

# Create project
kubectl apply -f argocd/project.yaml 

# SSH keys:
1. Github project settings - Deploy keys - Add deploy key - paste my_key.pub
2. ArgoCD settings - Repositories - CONNECT REPO - VIA SSH - paste my_key

# Create application
kubectl apply -f argocd/application.yaml
```

## Мониторинг кластера:
Для мониторинга используем Grafana с автоматически подключаемым в виде источника данных Prometheus. 
Мой дашборд мониторит падения и количество подов, а также шлет уведомления в телеграм при падении подов приложения. 
Сonfigmap используется для сохранения метрик в случае переустановки чарта. 
```
kubectl apply -f monitoring/configmap-grafana-dashboards.yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f monitoring/bokhanych-values.yaml --create-namespace --namespace monitoring
# Update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f monitoring/bokhanych-values.yaml --create-namespace --namespace monitoring
# Creds: admin \ prom-operator
```

## Логирование кластера:
Для работы с логами используем Grafana с автоматически подключаемым в виде источника данных Loki. В роли хранилища подключен бакет от яндекса.
```
# Manual: https://www.youtube.com/watch?v=MAKMxl_Um3s
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# LOKI install
# helm pull grafana/loki --untar
# cp loki/values.yaml loki-values.yaml
helm upgrade --install loki grafana/loki -f logging/loki-values.yaml --create-namespace --namespace logging

# PROMTAIL install
# helm pull grafana/promtail --untar
# cp promtail/values.yaml promtail-values.yaml
helm upgrade --install promtail grafana/promtail -f logging/promtail-values.yaml --create-namespace --namespace logging
```

## CI:
CI выполняется с помощью Github Actions. Запускается на кнопку, т.к. обновления образов у приложения выходят не часто. Скачивает мой репозиторий, логинится в dockerhub (используя секреты), берет за новую версию номер задачи, берет оригинальные образы приложения, тегирует их новой версией, отправляет в мой репозиторий [dockerhub](https://hub.docker.com/repository/docker/bokhanych/kubernetes-boutique/general), после чего меняет версию в манифесте приложения и пушит обновленный манифест в мой репозиторий, где его и замечает ArgoCD и разворачивает новую версию приложения. 


## Minio:
```
# Install the MinIO Operator using Helm Charts (устанавливается на control-plane ноды)
helm repo add minio-operator https://operator.min.io
helm search repo minio-operator
helm pull minio-operator/operator --untar
mv operator/values.yaml minio/operator-values.yaml
rm -r operator
helm install --namespace minio --create-namespace minio-operator minio-operator/operator --values minio/operator-values.yaml
kubectl get all -n minio
```

```
# Deploy a MinIO Tenant using Helm Charts
curl -sLo minio/tenant-values.yaml https://raw.githubusercontent.com/minio/operator/master/helm/tenant/values.yaml
helm install --namespace minio --create-namespace minio-tenant minio-operator/tenant --values minio/tenant-values.yaml
```