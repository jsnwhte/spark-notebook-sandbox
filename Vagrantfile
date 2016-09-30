Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	numNodes = 2
	r = numNodes..1
	(r.first).downto(r.last).each do |i|
		config.ssh.insert_key = false
		config.vm.define "spark-notebook#{i}" do |node|
			node.vm.box = "centos65"
			node.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.1/centos65-x86_64-20131205.box"
			node.vm.provider "virtualbox" do |v|
			  v.name = "spark-notebook#{i}"
			  v.customize ["modifyvm", :id, "--memory", "4096"]
			  v.customize ["modifyvm", :id, "--cpus", 1]
			end

			node.vm.network :private_network, ip: "10.10.10.1%02d" % i
			node.vm.hostname = "spark-notebook#{i}.example.com"
			node.vm.provision "shell", path: "scripts/setup-centos.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-centos-hosts.sh"
				s.args = "-t #{numNodes} -i #{i}"
			end
			node.vm.provision "shell", path: "scripts/setup-basic-packages.sh"
			node.vm.provision "shell", path: "scripts/setup-java.sh"
			node.vm.provision "shell", path: "scripts/setup-hadoop.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-hadoop-slaves.sh"
				s.args = "-s 1 -t #{numNodes}"
			end
			node.vm.provision "shell", path: "scripts/setup-spark.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-spark-slaves.sh"
				s.args = "-s 1 -t #{numNodes}"
			end
			if i == 1
				node.vm.provision "shell" do |s|
					s.path = "scripts/setup-centos-ssh.sh"
					s.args = "-s 1 -t #{numNodes}"
				end
			end
			node.vm.provision "shell", path: "scripts/setup-flume.sh"
			if i == 1
    			node.vm.provision "shell", path: "scripts/setup-spark-notebook.sh"
    		end
			node.vm.provision "shell", path: "scripts/setup-kafka.sh"
			if i == 1
				node.vm.provision "shell", path: "scripts/init-start-all-services.sh"
			end
		end
	end
end
