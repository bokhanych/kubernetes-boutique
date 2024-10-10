 **Проектная работа: "Инфраструктурная Managed k8s платформа для онлайн-магазина"**

 - [x] Создание кластера [Hetzner Cloud with Kubespray, HCLOUD Controller Manager and Storage Driver]
 - [x] Выбор приложения [GoogleCloudPlatform/microservices-demo]
 - [x] Присвоение меток нодам и запуск приложения только на нодах "worker"
 - [x] Изменение пространства имен приложения [onlineboutique]
 - [x] Непрерывная поставка [ArgoCD]
 - [x] Изменение количества реплик важных сервисов приложения
 - [x] Мониторинг кластера с datasource и dashboards [kube-prometheus-stack]
 - [x] Логирование кластера [grafana/loki,grafana/promtail]
 - [ ] Алерты и уведомления [Telegram]
 Kubernetes / Compute Resources / Namespace (Pods)
 - [ ] CI\CD пайплайн для приложения [Gitlab CI]


**Запуск приложения:**
1. Установка кластера *[инструкция в папке cluster]*
2. Установка argocd *[инструкция в папке argocd]*
3. Установка мониторинга *[инструкция в папке monitoring]*
4. Установка логирования *[инструкция в папке logging]*