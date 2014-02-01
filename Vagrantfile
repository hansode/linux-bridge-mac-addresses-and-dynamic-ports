# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-6.4-x86_64"

  config.vm.provision "shell", path: "bootstrap.sh"

  config.vm.define "node01" do |node|
    node.vm.hostname = "node01"
    node.vm.provision "shell", path: "config.d/common.sh"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh"
  end

  config.vm.define "node02" do |node|
    node.vm.hostname = "node02"
    node.vm.provision "shell", path: "config.d/common.sh"
    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh"
  end
end
