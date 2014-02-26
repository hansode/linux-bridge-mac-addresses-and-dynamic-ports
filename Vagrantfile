# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-6.4-x86_64"

  config.vm.provision "shell", path: "bootstrap.sh"     # Bootstrapping: package installation (phase:1)
  config.vm.provision "shell", path: "config.d/base.sh" # Configuration: node-common          (phase:2)

  config.vm.define "node01" do |node|
    node.vm.hostname = "node01"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
  end

  config.vm.define "node02" do |node|
    node.vm.hostname = "node02"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
  end

  # set static mac address to the linux bridge
  config.vm.define "node03" do |node|
    node.vm.hostname = "node03"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
  end

  # set static mac address to the linux bridge
  # set static mac address to the tap 00:00:00:00:00:01
  config.vm.define "node04" do |node|
    node.vm.hostname = "node04"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
  end

  # set static mac address to the linux bridge
  # set static mac address to the tap fe:ff:ff:ff:ff:ff
  config.vm.define "node05" do |node|
    node.vm.hostname = "node05"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
  end

  # set static mac address to the linux bridge
  # set static mac address to the tap 80:00:00:00:00:00
  config.vm.define "node06" do |node|
    node.vm.hostname = "node06"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
  end
end
