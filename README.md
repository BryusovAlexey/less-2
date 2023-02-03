# less-2
     ---Создать Raid 5---
[vagrant@Centos8-for-RAID ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf

[vagrant@Centos8-for-RAID ~]$ ls -l /dev/sd*
brw-rw----. 1 root disk 8,  0 Feb  1 22:19 /dev/sda
brw-rw----. 1 root disk 8,  1 Feb  1 22:19 /dev/sda1
brw-rw----. 1 root disk 8, 16 Feb  2 20:26 /dev/sdb
brw-rw----. 1 root disk 8, 32 Feb  2 20:26 /dev/sdc
brw-rw----. 1 root disk 8, 48 Feb  2 20:26 /dev/sdd
brw-rw----. 1 root disk 8, 64 Feb  2 20:26 /dev/sde
brw-rw----. 1 root disk 8, 80 Feb  2 20:26 /dev/sdf

[vagrant@Centos8-for-RAID ~]$ cat /proc/mdstst
cat: /proc/mdstst: No such file or directory
[vagrant@Centos8-for-RAID ~]$ sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
[vagrant@Centos8-for-RAID ~]$ cat /proc/mdstst
cat: /proc/mdstst: No such file or directory
[vagrant@Centos8-for-RAID ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

         ---Прописать Raid в конфигурацию---

[vagrant@Centos8-for-RAID /]$ mkdir /etc/mdadm
[vagrant@Centos8-for-RAID /]$ sudo -i
[root@Centos8-for-RAID ~]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
  
        ---Сломать|Починить Raid---

[root@Centos8-for-RAID ~]# mdadm /dev/md0 --fail /dev/sdb
mdadm: set /dev/sdb faulty in /dev/md0
[root@Centos8-for-RAID ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0](F)
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [_UUUU]
      
unused devices: <none>
[root@Centos8-for-RAID ~]# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Thu Feb  2 21:23:10 2023
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Thu Feb  2 22:26:07 2023
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : Centos8-for-RAID:0  (local to host Centos8-for-RAID)
              UUID : 8e4afaba:339d3ed3:6639fa7e:937c966a
            Events : 20

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf

       0       8       16        -      faulty   /dev/sdb
[root@Centos8-for-RAID ~]# mdadm /dev/md0 --remove /dev/sdb
mdadm: hot removed /dev/sdb from /dev/md0
[root@Centos8-for-RAID ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [_UUUU]
      
unused devices: <none>
[root@Centos8-for-RAID ~]# ^C
[root@Centos8-for-RAID ~]# mdadm /dev/md0 --add /dev/sdb
mdadm: added /dev/sdb
[root@Centos8-for-RAID ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdb[6] sdf[5] sde[3] sdd[2] sdc[1]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
