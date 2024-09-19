#!/bin/bash
sudo apt update
sudo apt install nfs-kernel-server
sudo mkdir -p /mnt/nfs_share
sudo chown nobody:nogroup /mnt/nfs_share
sudo chmod 777 /mnt/nfs_share
echo "/mnt/nfs_share *(rw,sync,no_subtree_check)">>/etc/exports
exportfs -a
systemctl restart nfs-kernel-server