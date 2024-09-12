# Здесь будет весь work-log работ по кластеру

Labels and Taints:
```
kubectl taint nodes node1 node-role.kubernetes.io/control-plane:NoSchedule
kubectl taint nodes node2 node-role.kubernetes.io/control-plane:NoSchedule
kubectl taint nodes node3 node-role.kubernetes.io/control-plane:NoSchedule
kubectl label nodes node4 node-role.kubernetes.io/worker=worker
kubectl label nodes node5 node-role.kubernetes.io/worker=worker

# kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    control-plane   34m   v1.30.4
node2   Ready    control-plane   33m   v1.30.4
node3   Ready    control-plane   33m   v1.30.4
node4   Ready    worker          32m   v1.30.4
node5   Ready    worker          32m   v1.30.4
```

**Запуск приложения:**
```
kubectl create namespace onlineboutique 
#kubectl config set-context --current --namespace=onlineboutique
kubectl apply -f boutique-app.yaml
kubectl apply -f ingress-boutique-app.yaml
```


TODO: 
 - [x] cluster + metallb
 - [x] labels, taints
 - [x] application replicas
 - [x] application namespace
 - [x] установка NFS сервиса на node1
 - [x] мониторинг
 - [] CI\CD
 - [] логирование

**NFS шара:**
```
root@node1:~# bash nfs-share.sh
```

**Мониторинг:**
```
kubectl apply -f ./grafana/grafana-install.yaml
kubectl create configmap grafana-dashboard-configmap --from-file=my-dashboard.json=/путь/к/файлу.json -n ваше-пространство-имен
```
