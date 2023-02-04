

### Simple sample of ruby for vagrant

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

#vagrant box add centos-8 https://mirrors.ustc.edu.cn/centos-cloud/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-20220913.0.x86_64.vagrant-virtualbox.box

# Vagrant Boxes Source Definition
Vagrant.configure("2") do | config |
  config.vm.box = "centos-8"

  #config.vm.box = "centos-8"
  config.vm.network "public_network", ip: "192.168.56.131"
  config.vm.provider "virtualbox" do |vb|
  vb.name = "Give me a better name"
   vb.gui = true
   #vb.cpus = 2
   vb.memory = "2048"
  config.vm.hostname = "OS-Centos8"
  config.vm.synced_folder "data", "/vagrant_data", type: "rsync"

    end
 end 
 
 



```
