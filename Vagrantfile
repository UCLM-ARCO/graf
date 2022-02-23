# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-buster64"

  config.vm.provision type="ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "provision.yml"
  end

end
