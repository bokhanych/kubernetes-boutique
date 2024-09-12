work-log работ по кластеру

# Labels:
```
kubectl label nodes cl1uf3p21pp8g9q34vki-eqaj node-role.kubernetes.io/worker=worker
kubectl label nodes cl1uf3p21pp8g9q34vki-ulyh node-role.kubernetes.io/worker=worker
kubectl label nodes cl1uf3p21pp8g9q34vki-ytap node-role.kubernetes.io/worker=worker

# kubectl get nodes
NAME                        STATUS   ROLES    AGE   VERSION
cl1uf3p21pp8g9q34vki-eqaj   Ready    worker   17h   v1.29.1
cl1uf3p21pp8g9q34vki-ulyh   Ready    worker   17h   v1.29.1
cl1uf3p21pp8g9q34vki-ytap   Ready    worker   17h   v1.29.1
```
# TODO: 
 - [x] Создание кластера
 - [x] Выбор приложения
 - [x] Присвоение меток нодам и запуск приложения только на нодах "worker"
 - [x] Изменение пространства имен приложения (onlineboutique)
 - [x] Непрерывная поставка (ArgoCD)
 - [x] Изменение количества реплик важных сервисов приложения
 - [] Мониторинг приложения и кластера
 - [] Логирование кластера
