# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :smartchat_web do |config|
    config.vm.box = "precise32"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    config.vm.network :forwarded_port, host: 4567, guest: 80
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', 4 * 1024, '--cpus', 2]
    end
  end
  config.vm.define :smartchat_worker do |config|
    config.vm.box = "precise32"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', 4 * 1024, '--cpus', 2]
    end
  end
  config.vm.define :smartchat_scheduler do |config|
    config.vm.box = "precise32"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', 4 * 1024, '--cpus', 2]
    end
  end
end
