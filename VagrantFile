# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	# vagrantshell machine
	config.vm.define "vagrantshell", primary: true do |vagrantshell|

		# Default box
		vagrantshell.vm.box = "bento/centos-6.7"
		#vagrantshell.vm.box_url = ""

		# Default shell
		#vagrantshell.ssh.shell = "/bin/bash"

		vagrantshell.vm.hostname = "vagrantshell"
		vagrantshell.vm.network :private_network, ip: "192.168.80.80"
		#vagrantshell.vm.network "forwarded_port", guest: 22, host: 4444, id: "ssh", auto_correct: true
		#vagrantshell.vm.network "forwarded_port", guest: 2368, host: 2368, auto_correct: true
		#vagrantshell.vm.network "forwarded_port", guest: 6081, host: 6081, auto_correct: true
		#vagrantshell.vm.network "forwarded_port", guest: 6379, host: 6379, auto_correct: true
		#vagrantshell.vm.network "forwarded_port", guest: 27017, host: 27017, auto_correct: true

		# NFS mounted with cachefilesd (FS-Cache) for performance.
		vagrantshell.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc']

		# Calculate CPU and memory usage for each provider.
		# https://stefanwrobel.com/how-to-make-vagrant-performance-not-suck

			host = RbConfig::CONFIG['host_os']
			# Give VM 1/4 system memory & access to all cpu cores on the host
			if host =~ /darwin/
				cpus = `sysctl -n hw.ncpu`.to_i
				# sysctl returns Bytes and we need to convert to MB
				mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
			elsif host =~ /linux/
				cpus = `nproc`.to_i
				# meminfo shows KB and we need to convert to MB
				mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
			else # Windows
				cpus = 2
				mem = 2048
			end

		# Define multiple providers: https://docs.vagrantup.com/v2/providers/configuration.html
		# Default provider order: https://docs.vagrantup.com/v2/providers/basic_usage.html

			# Provider: Parallels
			vagrantshell.vm.provider "parallels" do |p, override|
				override.vm.box = "parallels/centos-6.7"
				p.memory = mem
				p.cpus = cpus
				p.update_guest_tools = true
			end

			# Provider: VirtualBox
			vagrantshell.vm.provider "virtualbox" do |v|
				# https://docs.vagrantup.com/v2/virtualbox/configuration.html
				# This should be set by default already.
				#v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"] # https://github.com/mitchellh/vagrant/issues/713#issuecomment-17296765
				#v.customize ["modifyvm", :id, "--acpi", "off"]"
				#v.customize ["modifyvm", :id, "--ioapic", "on"] # http://vl4rl.com/2014/06/04/enabling-mulitcpu-vagrant-machines/
				v.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
				v.memory = mem
				v.cpus = cpus
				v.gui = false
			end

		vagrantshell.vm.post_up_message = "vagrantshell documentation: https://github.com/danemacmillan/vagrantshell."

		vagrantshell.vm.provision "shell", path: "provision.sh"
	end
end
