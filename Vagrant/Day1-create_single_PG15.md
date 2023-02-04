
### Pre-req

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
  
  config.vm.provision "shell", path: "https://github.com/joe-wan-cn/IT-infra/blob/main/PG/PG15/Day1-Install_single_DB.sh"

  end 
 end 

```



