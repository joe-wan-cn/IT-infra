
### Pre-re

- install the virtrulbox in your laptop

- install the vagrant-disksize otherthan the default size couldnt' be change and fix to 10GB.
vagrant plugin install vagrant-disksize

- Note please, if you aren't based in China, do comment the fragrament for the optional 1


### Simple sample of ruby for vagrant

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

#https://mirrors.tuna.tsinghua.edu.cn/help/centos/ 
#vagrant box add centos-8 https://mirrors.ustc.edu.cn/centos-cloud/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-20220913.0.x86_64.vagrant-virtualbox.box

# Vagrant Boxes Source Definition

 $script = <<-SCRIPT
  # dnf upgrade
  
  #update the timezone 
  #timedatectl set-timezone Asia/Shanghai	
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
  # Replce the default centos  (optional 1)
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo
  dnf makecache
  # update the passwd for root
  echo redhat | passwd root --stdin
SCRIPT


Vagrant.configure("2") do | config |
  config.vm.box = "centos-8"

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
