Сначала установим заголовки ядра [на всех нодах]:

`apt-get install linux-headers-$(uname -r) -y`

Потом добавим репозиторий ppa [на всех нодах]:

`add-apt-repository ppa:linbit/linbit-drbd9-stack`

`apt-get update`

Установим эти пакеты [на всех нодах]:

 `apt install drbd-utils drbd-dkms lvm2 -y`

Загрузим модуль ядра DRBD [на всех нодах]:

`modprobe drbd usermode_helper=disabled`

Проверим, что он точно загрузился [на всех нодах]:

`lsmod | grep -i drbd`

Убедимся, что он автоматически загружается при запуске [на всех нодах]:

`echo drbd usermode_helper=disabled > /etc/modules-load.d/drbd.conf`

Кластер Linstor состоит из одного активного контроллера, который управляет всей информацией о кластере, и спутников — нод, которые предоставляют хранилище [на контроллере]:

`apt install linstor-controller linstor-satellite linstor-client`

Эта команда делает контроллер еще и спутником. В моем случае контроллером был node1. Чтобы сразу запустить контроллер и включить его автоматический запуск при загрузке, выполним команду [на контроллере]:

`systemctl enable --now linstor-controller`

`systemctl start linstor-controller`

Установим следующие пакеты [на спутниках]:

`apt install linstor-satellite linstor-client -y`

Запустим спутник и сделаем так, чтобы он запускался при загрузке [на спутниках]:

`systemctl enable --now linstor-satellite`
`systemctl start linstor-satellite` 

Теперь можно добавить к контролеру спутники, включая саму эту ноду [на контроллере]:

```
linstor node create node1 10.98.0.2
linstor node create node2 10.98.0.3
linstor node create node3 10.98.0.4
linstor node create node4 10.98.0.5
linstor node create node5 10.98.0.6
```
Проверим харды под линстор [на спутниках]:

`lsblk`

Подготовим диски на каждом узле. В моем случае это /dev/sdb [на спутниках]:

`vgcreate linstor /dev/sdb`

Теперь создадим «тонкий» пул для thin provisioning (то есть возможности создавать тома больше доступного места, чтобы потом расширять хранилище по необходимости) и снапшотов [на спутниках]:

`lvcreate -l 100%FREE --thinpool linstor/lvmthinpool`

Пора создать пул хранилища на каждой ноде, так что выполняем команду [на контроллере]:

```
linstor storage-pool create lvmthin node1 linstor-pool linstor/lvmthinpool
linstor storage-pool create lvmthin node2 linstor-pool linstor/lvmthinpool
linstor storage-pool create lvmthin node3 linstor-pool linstor/lvmthinpool
linstor storage-pool create lvmthin node4 linstor-pool linstor/lvmthinpool
linstor storage-pool create lvmthin node5 linstor-pool linstor/lvmthinpool
```

Убедимся, что пул создан [на контроллере]:

```
# linstor node list
╭─────────────────────────────────────────────────────╮
┊ Node  ┊ NodeType  ┊ Addresses              ┊ State  ┊
╞═════════════════════════════════════════════════════╡
┊ node1 ┊ SATELLITE ┊ 10.98.0.2:3366 (PLAIN) ┊ Online ┊
┊ node2 ┊ SATELLITE ┊ 10.98.0.3:3366 (PLAIN) ┊ Online ┊
┊ node3 ┊ SATELLITE ┊ 10.98.0.4:3366 (PLAIN) ┊ Online ┊
┊ node4 ┊ SATELLITE ┊ 10.98.0.5:3366 (PLAIN) ┊ Online ┊
┊ node5 ┊ SATELLITE ┊ 10.98.0.6:3366 (PLAIN) ┊ Online ┊
╰─────────────────────────────────────────────────────╯
# linstor storage-pool list
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ StoragePool          ┊ Node  ┊ Driver   ┊ PoolName            ┊ FreeCapacity ┊ TotalCapacity ┊ CanSnapshots ┊ State ┊ SharedName                 ┊
╞══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ DfltDisklessStorPool ┊ node1 ┊ DISKLESS ┊                     ┊              ┊               ┊ False        ┊ Ok    ┊ node1;DfltDisklessStorPool ┊
┊ DfltDisklessStorPool ┊ node2 ┊ DISKLESS ┊                     ┊              ┊               ┊ False        ┊ Ok    ┊ node2;DfltDisklessStorPool ┊
┊ DfltDisklessStorPool ┊ node3 ┊ DISKLESS ┊                     ┊              ┊               ┊ False        ┊ Ok    ┊ node3;DfltDisklessStorPool ┊
┊ DfltDisklessStorPool ┊ node4 ┊ DISKLESS ┊                     ┊              ┊               ┊ False        ┊ Ok    ┊ node4;DfltDisklessStorPool ┊
┊ DfltDisklessStorPool ┊ node5 ┊ DISKLESS ┊                     ┊              ┊               ┊ False        ┊ Ok    ┊ node5;DfltDisklessStorPool ┊
┊ linstor-pool         ┊ node1 ┊ LVM_THIN ┊ linstor/lvmthinpool ┊     9.97 GiB ┊      9.97 GiB ┊ True         ┊ Ok    ┊ node1;linstor-pool         ┊
┊ linstor-pool         ┊ node2 ┊ LVM_THIN ┊ linstor/lvmthinpool ┊     9.97 GiB ┊      9.97 GiB ┊ True         ┊ Ok    ┊ node2;linstor-pool         ┊
┊ linstor-pool         ┊ node3 ┊ LVM_THIN ┊ linstor/lvmthinpool ┊     9.97 GiB ┊      9.97 GiB ┊ True         ┊ Ok    ┊ node3;linstor-pool         ┊
┊ linstor-pool         ┊ node4 ┊ LVM_THIN ┊ linstor/lvmthinpool ┊     9.97 GiB ┊      9.97 GiB ┊ True         ┊ Ok    ┊ node4;linstor-pool         ┊
┊ linstor-pool         ┊ node5 ┊ LVM_THIN ┊ linstor/lvmthinpool ┊     9.97 GiB ┊      9.97 GiB ┊ True         ┊ Ok    ┊ node5;linstor-pool         ┊
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

Подключаем PersistentStorage к kubernetes-кластеру, используя piraeus:
```
LINSTOR_CONTROLLER_URL=http://10.98.0.2:3370 #ip-address-controller-node
kubectl kustomize http://github.com/piraeusdatastore/linstor-csi/examples/k8s/deploy   | sed "s#LINSTOR_CONTROLLER_URL#$LINSTOR_CONTROLLER_URL#"   | kubectl apply --server-side -f -
```

Добавляем StorageClass:
```
kubectl apply -f StorageClass.yaml
```

Развернем под для проверки:
```
kubectl apply -f testpvc.yaml 
kubectl apply -f testpod.yaml
```

Смена стандартного storageclass на linstor. Сначала нужно убрать тег с текущего стандартного, затем поставить на новый стандартный storageclass:
```
kubectl patch storageclass hcloud-volumes -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass linstor -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}
```

Установка linstor-gui [на контроллере]:
```
sudo add-apt-repository ppa:linbit/linbit-drbd9-stack
sudo apt install linstor-gui
```