#!/bin/bash
# https://github.com/joe-wan-cn/IT-infra/blob/main/Vagrant/Day1-create_single_boxes.md 
# simple script for vagrant to call this script to setup the PG15 single DB  <<< applicable for vagrant environment only

# Put the commands inside here


#update the timezone 
#timedatectl set-timezone Asia/Shanghai	
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


# update the passwd for root
echo redhat | passwd root --stdin


# Replce the default centos  (optional 1)
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
      -i.bak \
      /etc/yum.repos.d/CentOS-*.repo

# dnf makecache

# dnf upgrade

# Install the repository RPM:
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module:
dnf -qy module disable postgresql

# Install PostgreSQL:
dnf install -y postgresql15-server

# Place the data into special folder but not the default one 
mkdir -p /pgsql/15/{data,dump,dba,backup}
chown -R postgres:postgres /pgsql
chmod -R 700 /pgsql 
echo "export PATH=/usr/pgsql-15/bin:$PATH">> /etc/profile
 
echo "export PGHOME=/pgsql/15" >> /var/lib/pgsql/.bash_profile
echo "export PGDATA=/pgsql/15/data " >> /var/lib/pgsql/.bash_profile
echo "export PGDUMP=/pgsql/15/dump  " >> /var/lib/pgsql/.bash_profile
echo "export PGBACKUP=/pgsql/15/backup " >> /var/lib/pgsql/.bash_profile

sed -e 's|Environment=PGDATA=/var/lib/pgsql/15/data/|Environment=PGDATA=/pgsql/15/data/|g' -i.bak /usr/lib/systemd/system/postgresql-15.service


# initialize the database and enable automatic start:
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15


