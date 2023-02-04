


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

- Note please, if you aren't based in China, do comment the fragrament for the optional 1



### Vagrantfile to bulk create 3 boxes 

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

#https://mirrors.tuna.tsinghua.edu.cn/help/centos/ 
#vagrant box add centos-8 https://mirrors.ustc.edu.cn/centos-cloud/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-20220913.0.x86_64.vagrant-virtualbox.box

# Vagrant Boxes Source Definition


 $script = <<-SCRIPT
  # Put the script or commands inside here
 
  
  #update the timezone 
  #timedatectl set-timezone Asia/Shanghai	
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
  # Replce the default centos 
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo

  # update the passwd for root
  echo redhat | passwd root --stdin
  
   # dnf upgrade
SCRIPT

# Vagrant setting started
Vagrant.configure("2") do |config|
   (1..3).each do |i|
        # setup the Vagrant name for the box prefix with V-CentOS-8
        config.vm.define "V-CentOS-8#{i}" do |node|
            # VM BOX image
            node.vm.box = "centos-8"

            # OS hosntmae
            node.vm.hostname="OS-Centos8#{i}"

            # setup the private IP
            # node.vm.network "private_network", ip: "172.30.10.#{10+i}", netmask: "255.255.255.0"
			
			 # setup the public IP
			node.vm.network "public_network", ip: "192.168.56.#{132+i}", netmask: "255.255.255.0"
			

            # setup the shared folder
            node.vm.synced_folder ".", "/vagrant_data", type: "rsync"
			
            # VirtaulBox settings
            node.vm.provider "virtualbox" do |v|
                # VMbox Name
                v.name = "Give me a better name#{i}"
                # OS Memory
                v.memory = 2048
                # OS CPUS
                #v.cpus = 2
            end
        end
        # setup the disk size to 30GB rather than the default 10GB
        # config.disksize.size = '30GB'
		config.vm.provision "shell", inline: $script
   end
end
```
