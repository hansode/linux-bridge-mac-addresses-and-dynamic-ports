# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-6.4-x86_64"

  config.vm.provision "shell", path: "bootstrap.sh"     # Bootstrapping: package installation (phase:1)
  config.vm.provision "shell", path: "config.d/base.sh" # Configuration: node-common          (phase:2)

  # node03
  # + set static mac address to the linux bridge
  # node04
  # + set static mac address to the linux bridge
  # + set static mac address to the tap 00:00:00:00:00:01
  # node05
  # + set static mac address to the linux bridge
  # + set static mac address to the tap fe:ff:ff:ff:ff:ff
  # node06
  # + set static mac address to the linux bridge
  # + set static mac address to the tap 80:00:00:00:00:00

  (1..6).each { |id|
    name = sprintf("node%02d", id)

    config.vm.define "#{name}" do |node|
      node.vm.hostname = "#{name}"
      node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
    end
  }
end
