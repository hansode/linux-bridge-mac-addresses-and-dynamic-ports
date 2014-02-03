# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-6.4-x86_64"

  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.provision "shell", path: "config.d/base.sh"

  config.vm.define "node01" do |node|
    node.vm.provision "shell", path: "config.d/node01.sh"
  end

  config.vm.define "node02" do |node|
    node.vm.provision "shell", path: "config.d/node02.sh"
  end

  # set static mac address to the linux bridge
  config.vm.define "node03" do |node|
    node.vm.provision "shell", path: "config.d/node03.sh"
  end

  # set static mac address to the linux bridge
  # set static mac address to the tap 00:00:00:00:00:01
  config.vm.define "node04" do |node|
    node.vm.provision "shell", path: "config.d/node04.sh"
  end

  # set static mac address to the linux bridge
  # set static mac address to the tap fe:ff:ff:ff:ff:ff
  config.vm.define "node05" do |node|
    node.vm.provision "shell", path: "config.d/node05.sh"
  end

  # set static mac address to the linux bridge
  # set static mac address to the tap 80:00:00:00:00:00
  config.vm.define "node06" do |node|
    node.vm.provision "shell", path: "config.d/node06.sh"
  end
end
