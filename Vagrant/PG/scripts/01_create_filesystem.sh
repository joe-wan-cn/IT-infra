#!/bin/bash

. /vagrant/config/setup.env

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Setting-up /u01 disk"
echo "-----------------------------------------------------------------"
# Single GPT partition for the whole disk
BOX_DISK_NUM=$1
PROVIDER=$2
DB_NAME=$3

if [ "${PROVIDER}" == "libvirt" ]; then
  DEVICE="vd"
elif [ "${PROVIDER}" == "virtualbox" ]; then
  DEVICE="sd"
else
  echo "Not supported provider: ${PROVIDER}"
  exit 1
fi

LETTER=`tr 0123456789 abcdefghij <<< $BOX_DISK_NUM`
parted -s -a optimal /dev/${DEVICE}${LETTER} mklabel gpt -- mkpart primary 2048s 100%

# LVM setup
pvcreate /dev/${DEVICE}${LETTER}1
vgcreate vg_pg01 /dev/${DEVICE}${LETTER}1
lvcreate -l 100%FREE -n lv_pgdata vg_pg01

# Make XFS
mkfs.xfs -f /dev/vg_pg01/lv_pgdata

# Set fstab
UUID=`blkid -s UUID -o value /dev/vg_pg01/lv_pgdata`

mkdir -p /pgsql/${DB_NAME}/15/{data,dump,dba,backup}

cat >> /etc/fstab <<EOF
UUID=${UUID}   /pgsql/${DB_NAME}    xfs    defaults 0 0 
EOF

# Mount
sudo mount /pgsql/${DB_NAME}



