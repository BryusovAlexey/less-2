#!/bin/bash
# Обновление пакетов
yum -y update

# Установка утилиты управления программными RAID 
sudo yum -y install mdadm smartmontools hdparm gdisk

# Зануление суперблоков
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}

# Создание рейда 5 из 5 дисков
sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}


# sudo sh -c "echo 'DEVICE partitions' > /etc/mdadm/mdadm.conf"
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
# sudo mdadm --detail --scan --verbose | sudo sh -c "awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf"

# Создание разделов GPT
sudo parted -s /dev/md0 mklabel gpt
sudo parted /dev/md0 mkpart part_1 ext4 0% 20%
sudo parted /dev/md0 mkpart part_2 ext4 20% 40%
sudo parted /dev/md0 mkpart part_3 ext4 40% 60%
sudo parted /dev/md0 mkpart part_4 ext4 60% 80%
sudo parted /dev/md0 mkpart part_5 ext4 80% 100%

# Создание файловых систем 
sudo mkfs.ext4 /dev/md0p1
sudo mkfs.ext4 /dev/md0p2
sudo mkfs.ext4 /dev/md0p3
sudo mkfs.ext4 /dev/md0p4
sudo mkfs.ext4 /dev/md0p5

# Создание точек монтирования
sudo mkdir /mnt/part_1
sudo mkdir /mnt/part_2
sudo mkdir /mnt/part_3
sudo mkdir /mnt/part_4
sudo mkdir /mnt/part_5


# Добавление разделов в vfstab
# echo "/dev/md0p1 /mnt/part_1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo echo "/dev/md0p1 /mnt/part_1 ext4 defaults 0 0" | tee -a /etc/fstab
sudo echo "/dev/md0p2 /mnt/part_2 ext4 defaults 0 0" | tee -a /etc/fstab
sudo echo "/dev/md0p3 /mnt/part_3 ext4 defaults 0 0" | tee -a /etc/fstab
sudo echo "/dev/md0p4 /mnt/part_4 ext4 defaults 0 0" | tee -a /etc/fstab
sudo echo "/dev/md0p5 /mnt/part_5 ext4 defaults 0 0" | tee -a /etc/fstab

# Перезагрузка ВМ
shutdown -r now
