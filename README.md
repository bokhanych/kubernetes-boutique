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
 - [x] Присвоение меток нодам
 - [x] Выбор приложения
 - [] Изменение количества реплик важных сервисов приложения
 - [x] Изменение пространства имен приложения (onlineboutique)
 - [] Мониторинг приложения и кластера
 - [x] Непрерывная поставка (ArgoCD)
 - [] Логирование кластера
