Vagrant.configure("2") do |config|

  config.vm.define "dc" do |cfg|
    cfg.vm.box = "detectionlab/win2016"
    cfg.vm.hostname = "dc"
    cfg.vm.boot_timeout = 600
    cfg.winrm.transport = :plaintext
    cfg.vm.communicator = "winrm"
    cfg.winrm.basic_auth_only = true
    cfg.winrm.timeout = 300
    cfg.winrm.retry_limit = 20
    cfg.vm.network :private_network, ip: "192.168.56.10", gateway: "192.168.56.1", dns: "8.8.8.8"

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.name = "dc.windomain.local"
      vb.customize ["modifyvm", :id, "--cpus", 2]
      vb.customize ["modifyvm", :id, "--memory", 4096]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end

    cfg.vm.provision "shell", path: "demo/01_prepare.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "demo/02_create_forest.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "demo/03_create_objects.ps1", privileged: false
    cfg.vm.provision "shell", path: "create_orgchart.ps1", args: '-OutputFile C:\vagrant\cypher.txt -CompromisedUsersFile C:\vagrant\demo\Users_Compromised.csv', privileged: false
  end
end
