
### 1. 背景
OS version: RHEL7.9
用户误操作删除了应用系统中的文件，基于操作系统都是vm机器，并且vmsphere只有snapshot备份，因此采用恢复vm snapshot后将需要的存储挂在到新的OS上，从而实现LV恢复数据。

### 2. 准备工作
> 本文已经服务器名替换成xxxxx 

将删除之前的snapshot恢复回来得到 xxxxx_snapshot的vm，然后将xxxxx_snapshot里边的磁盘都挂载在xxxxx 服务器上。

### 3. 恢复过程

#### 3.1 核实当前LVM各卷情况
```
snapshot里边的磁盘挂载到服务器上，通过命令可以看到如下

[root@xxxxxx]# pvs
  WARNING: Not using lvmetad because duplicate PVs were found.
  WARNING: Use multipath or vgimportclone to resolve duplicate PVs?
  WARNING: After duplicates are resolved, run "pvscan --cache" to enable lvmetad.
  WARNING: Not using device /dev/sdc2 for PV FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr.
  WARNING: Not using device /dev/sdd1 for PV FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF.
  WARNING: PV FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr prefers device /dev/sda2 because device is used by LV.
  WARNING: PV FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF prefers device /dev/sdb1 because device is used by LV.
  PV         VG   Fmt  Attr PSize    PFree
  /dev/sda2  vg00 lvm2 a--   <59.00g 1020.00m
  /dev/sdb1  vg01 lvm2 a--  <500.00g  <85.00g


[root@xxxxxx]# blkid
/dev/mapper/vg00-lv_var_crash: UUID="be701d4f-404c-488a-bfc3-1664e369e8a7" TYPE="xfs"
/dev/sdb1: UUID="FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF" TYPE="LVM2_member" PARTLABEL="primary" PARTUUID="eacd291f-e38a-45cb-95ed-7eb4f7043340"
/dev/sda1: LABEL="/boot" UUID="296dd6b6-ff16-4202-9b3d-0c932f3102a3" TYPE="xfs"
/dev/sda2: UUID="FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr" TYPE="LVM2_member"
/dev/mapper/vg00-lv_root: UUID="d3bfeeed-4b5a-4b01-b1f5-b79cd50b49d6" TYPE="xfs"
/dev/mapper/vg00-lv_swap01: UUID="f7251250-d76a-4c2f-9e50-c00a9fa328ca" TYPE="swap"
/dev/mapper/vg00-lv_opt: UUID="9b7fc021-5468-4ae7-b6e3-3a60603837d8" TYPE="xfs"
/dev/mapper/vg00-lv_tmp: UUID="0a657824-c64d-4b05-94bb-1c49ef86b03b" TYPE="xfs"
/dev/mapper/vg00-lv_var_log: UUID="1497dccc-2914-4a4e-8ca4-3d73c9b443d5" TYPE="xfs"
/dev/mapper/vg00-lv_var: UUID="34e33e79-f795-4806-b6d8-dea69f4a6c95" TYPE="xfs"
/dev/mapper/vg00-lv_home: UUID="64a18d8e-2b25-47a2-8316-d0d398f4aa8a" TYPE="xfs"
/dev/mapper/vg01-lv_replace1: UUID="4d8be780-556e-438d-8480-9c13e2c234b7" TYPE="ext4"
/dev/mapper/vg01-lv_replace2: UUID="9ec272b5-10a0-4a59-8eb5-11f722ec62ae" TYPE="ext4"
/dev/sdc1: LABEL="/boot" UUID="296dd6b6-ff16-4202-9b3d-0c932f3102a3" TYPE="xfs"
/dev/sdc2: UUID="FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr" TYPE="LVM2_member"
/dev/sdd1: UUID="FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF" TYPE="LVM2_member" PARTLABEL="primary" PARTUUID="eacd291f-e38a-45cb-95ed-7eb4f7043340"
```

#### 3.2 通过 vgimportclone重命名 vg 名

```
[root@xxxxxx ]#  systemctl stop lvm2-lvmetad
Warning: Stopping lvm2-lvmetad.service, but it can still be activated by:
  lvm2-lvmetad.socket
  --  忽略错误 继续
  
[root@xxxxxx ]# vgimportclone --basevgname vg00-snap /dev/sdc2
  WARNING: Not using device /dev/sdc2 for PV FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr.
  WARNING: Not using device /dev/sdd1 for PV FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF.
  WARNING: PV FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr prefers device /dev/sda2 because device is used by LV.
  WARNING: PV FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF prefers device /dev/sdb1 because device is used by LV.
  WARNING: found device with duplicate /dev/sdd1
  WARNING: Disabling lvmetad cache which does not support duplicate PVs.
  WARNING: Scan found duplicate PVs.
  WARNING: Failed to scan devices.
  WARNING: Update lvmetad with pvscan --cache.
  --  忽略错误 继续
  
[root@xxxxxx ]# vgimportclone --basevgname vg01-snap /dev/sdd1
  WARNING: Not using device /dev/sdc2 for PV FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr.
  WARNING: Not using device /dev/sdd1 for PV FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF.
  WARNING: PV FkvhPq-uaXD-fUbz-N5Qy-3tuD-dDhg-46hLIr prefers device /dev/sda2 because device is used by LV.
  WARNING: PV FrfoKN-l3cu-AmLg-MqQP-oEE5-NNzw-rehZYF prefers device /dev/sdb1 because device is used by LV.
  WARNING: found device with duplicate /dev/sdd1
  WARNING: Disabling lvmetad cache which does not support duplicate PVs.
  WARNING: Scan found duplicate PVs.
  WARNING: Failed to scan devices.
  WARNING: Update lvmetad with pvscan --cache.
  --  忽略错误 继续
   
  
[root@xxxxxx ]#  pvscan --cache
 
此时，可以看到所需要的VG,LV都已经到位

-- 最后只需要创建mount point，然后挂载
mount /dev/vg01-snap/vg01-lv_replace2 /new_point 

-- 然后通过用户去核对恢复对应的文件
 ```

### 4. 安全的删除snapshot的磁盘
用户恢复完对应的文件后，需要把snapshot磁盘从现有OS里边卸载出来，步骤如下
```
-- umount文件系统
umount /new_point 


-- deattach the vg

vgchange -an vg01-snap
vgchange -an vg00-snap


-- delete the snapshot disks
echo 1 > /sys/block/sdc/device/delete
echo 1 > /sys/block/sdd/device/delete

-- ask the vm team to remove the snapshot disks

```


### 5. 后记
```
关于此类操作，常用的命令就是importvgclone ,vgchange

```



