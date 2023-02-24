#!/bin/bash
os_version=`cat /etc/redhat-release  | awk '{print $6}' | awk -F'.' '{print $1}'`

if [ ${os_version} = "8" ];then 
    dnf -y install lvm2
else 
   yum -y install lvm2
fi

echo redhat | passwd root --stdin


