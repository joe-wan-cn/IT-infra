#!/bin/bash
# Create the relevant FS 

run_user_scripts() {
  # run user-defined post-setup scripts
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Running user-defined post-setup scripts"
  echo "-----------------------------------------------------------------"
  for f in /Vagrant/userscripts/*
    do
      case "${f,,}" in
        *.sh)
          echo -e "${INFO}`date +%F' '%T`: running $f"
          . "$f"
          echo -e "${INFO}`date +%F' '%T`: Done running $f"
          ;;
        *.sql)
          echo -e "${INFO}`date +%F' '%T`: running $f"
          su -l oracle -c "echo 'exit' | sqlplus -s / as sysdba @\"$f\""
          echo -e "${INFO}`date +%F' '%T`: Done running $f"
          ;;
        /Vagrant/userscripts/put_custom_scripts_here.txt)
          :
          ;;
        *)
          echo -e "${INFO}`date +%F' '%T`: ignoring $f"
          ;;
      esac
    done
}

os_version=`cat /etc/redhat-release  | awk '{print $6}' | awk -F'.' '{print $1}'`

if [ ${os_version} = "8" ];then 
    dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    dnf -qy module disable postgresql
else 
   sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
fi


#--- in case of the server rebooted
mount -t vboxsf vagrant /vagrant


cat <<EOL > /vagrant/config/setup.env
export INFO='\033[0;34mINFO: \033[0m'
export ERROR='\033[1;31mERROR: \033[0m'
export SUCCESS='\033[1;32mSUCCESS: \033[0m'
EOL


echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Setup the environment variables"
echo "-----------------------------------------------------------------"
. /vagrant/config/setup.env


#--------------------------------------------------------------------
# Setting-up /u01 disk

bash /vagrant/scripts/02_install_packages.sh

bash /vagrant/scripts/01_create_filesystem.sh 1 virtualbox ${DB_NAME}

# Install PostgreSQL software:
dnf install -y postgresql${PG_VERSION}-server

# postgres:x:26:26:PostgreSQL Server:/var/lib/pgsql:/bin/bash <__________ 这里需要再调整哈

PG_DEFAULT_OWNER=`id postgres`

if [ $? = "0" ];then 
   userdel -fr ${PG_OWNER} 2> /dev/null
   groupadd postgres  2> /dev/null
   useradd -g postgres ${PG_OWNER} 2> /dev/null

else 
   groupadd postgres 2> /dev/null
   useradd -g postgres ${PG_OWNER}   2> /dev/null
fi


echo "export PATH=/usr/pgsql-${PG_VERSION}/bin:$PATH">> /etc/profile

echo "export PGHOME=/pgsql/${DB_NAME}/${PG_VERSION}" >> /home/${PG_OWNER}/.bash_profile

echo "export PGDATA=/pgsql/${DB_NAME}/${PG_VERSION}/data " >> /home/${PG_OWNER}/.bash_profile

echo "export PGDUMP=/pgsql/${DB_NAME}/${PG_VERSION}/dump  " >> /home/${PG_OWNER}/.bash_profile

echo "export PGBACKUP=/pgsql/${DB_NAME}/${PG_VERSION}/backup " >> /home/${PG_OWNER}/.bash_profile

sed "s|Environment=PGDATA=/var/lib/pgsql/${PG_VERSION}/data|Environment=PGDATA=/pgsql/${DB_NAME}/${PG_VERSION}/data|g"  /usr/lib/systemd/system/postgresql-${PG_VERSION}.service -i

sed "s|User=postgres|User=${PG_OWNER}|g"  /usr/lib/systemd/system/postgresql-${PG_VERSION}.service -i

sed "s|# StandardOutput=syslog|StandardOutput=syslog|g"  /usr/lib/systemd/system/postgresql-${PG_VERSION}.service -i


sudo /usr/pgsql-${PG_VERSION}/bin/postgresql-${PG_VERSION}-setup initdb

sleep 3

# Avoid the error for could not create lock file "/var/run/postgresql/.s.PGSQL.5432.lock": Permission denied
# Only required to change when run the PG instance name without postgres
#sed -i "s|#unix_socket_directories = '/var/run/postgresql, /tmp'|unix_socket_directories = '/tmp ,/var/run/postgresql '|g"  /pgsql/${DB_NAME}/${PG_VERSION}/data/postgresql.conf 
sudo chown -R ${PG_OWNER}:postgres /var/run/postgresql

sudo chown -R ${PG_OWNER}:postgres /pgsql

sudo chgrp -R postgres /pgsql

sudo systemctl enable postgresql-${PG_VERSION}

sudo systemctl start postgresql-${PG_VERSION}

sudo systemctl status postgresql-${PG_VERSION}


# Run the cumster scripts 
run_user_scripts;

