
### Pre-req
- call the remote script to build the PG15
https://github.com/joe-wan-cn/IT-infra/edit/main/Vagrant/Day1-create_single_PG15_remote.md

- install the virtrulbox in your laptop

- install the vagrant-disksize otherthan the default size couldnt' be change and fix to 10GB.
```
vagrant plugin install vagrant-disksize
```
- add the vagrant rhel8 box by manual first
```
vagrant box add centos-8 https://mirrors.ustc.edu.cn/centos-cloud/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-20220913.0.x86_64.vagrant-virtualbox.box
```

- Script called from https://github.com/joe-wan-cn/IT-infra/tree/main/PG/PG15


- Note please, if you aren't based in China, do comment the fragrament for the optional 1


### About shell inside vagrant

Vagrant can call the script from guest os , local , remote website like github and same simple from windows server with powershell
https://developer.hashicorp.com/vagrant/docs/provisioning/shell


### Simple sample of ruby for vagrant

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

#https://mirrors.tuna.tsinghua.edu.cn/help/centos/ 

# Vagrant Boxes Source Definition
 $script = <<-SCRIPT
  # Put the commands inside here
  
  
  #update the timezone 
  #timedatectl set-timezone Asia/Shanghai	
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
  # Replce the default centos  (optional 1)
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo
 
  # update the passwd for root
  echo redhat | passwd root --stdin
  
  # dnf upgrade
  # Install the repository RPM:
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module:
sudo dnf -qy module disable postgresql

# Install PostgreSQL:
sudo dnf install -y postgresql15-server

# Optionally initialize the database and enable automatic start:
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15


SCRIPT


Vagrant.configure("2") do | config |
  config.vm.box = "centos-8"

  #Setup the vagrant name for this box
  config.vm.define "V-CentOS-8"
  
  #Size for th vm box
  #config.vm.disksize.size = '30GB' 

  config.vm.network "public_network", ip: "192.168.56.131"
  
  config.vm.hostname = "OS-Centos8"
  # Dont forget to append  rysnc
  config.vm.synced_folder ".", "/vagrant_data", type: "rsync"
  
  config.vm.provider "virtualbox" do |vb|
  # vmbox's name
  vb.name = "Give me a better name"  
  # turn GUI on
  vb.gui = true
  #vb.cpus = 2
  vb.memory = "2048"
  
  config.vm.provision "shell", inline: $script
   
  end 
 end 
```
