# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
    config.vm.provision "shell", path: "install-k8s/bootstrap.sh"

    # Kubernetes Master Server
    config.vm.define "kmaster" do |kmaster|
        file_to_disk1 = "disks/sdb_disk_master.vdi"
        kmaster.vm.synced_folder ".", "/vagrant", type: "virtualbox"
        kmaster.vm.box = "centos/7"
        kmaster.vm.hostname = "kmaster"
        kmaster.vm.network :private_network, ip: "192.168.60.10"
        kmaster.vm.provider "virtualbox" do |vb|

            unless File.exist?(file_to_disk1)
                vb.customize ['createhd', '--filename', file_to_disk1, '--variant', 'Fixed', '--size', 5 * 1024]
            end
            vb.customize ['storageattach', :id,  '--storagectl', "IDE", '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk1]
        
            vb.memory = "2048"
            vb.name = "kmaster"
            vb.cpus = 2
        end
        kmaster.vm.provision "shell", path: "install-k8s/bootstrap_kmaster.sh"
    end

    # Kubernetes Worker Nodes
    (1..3).each do |i|
        config.vm.define "kworker#{i}" do |kworker|
            file_to_disk1 = "disks/sdb_disk_worker#{i}.vdi"
            file_to_disk2 = "disks/sdc_disk_worker#{i}.vdi"
            kworker.vm.synced_folder ".", "/vagrant", type: "virtualbox"
            kworker.vm.box = "centos/7"
            kworker.vm.hostname = "kworker#{i}"
            kworker.vm.network :private_network, ip: "192.168.60.1#{i}"
            # kworker.vm.provision :ansible, playbook: "install-etcd/etcd-playbook.yaml"
            kworker.vm.provider "virtualbox" do |vb|
                unless File.exist?(file_to_disk1)
                    vb.customize ['createhd', '--filename', file_to_disk1, '--variant', 'Fixed', '--size', 32 * 1024]
                end
                vb.customize ['storageattach', :id,  '--storagectl', "IDE", '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk1]
            
                unless File.exist?(file_to_disk2)
                   vb.customize ['createhd', '--filename', file_to_disk2, '--variant', 'Fixed', '--size', 8 * 1024]
                end
                vb.customize ['storageattach', :id,  '--storagectl', "IDE", '--port', 1, '--device', 1, '--type', 'hdd', '--medium', file_to_disk2]

                vb.memory = "6144"
                vb.name = "kworker#{i}"
                vb.cpus = 4
            end
            kworker.vm.provision "shell", path: "install-k8s/bootstrap_kworker.sh"
    end
end

end


#kubectl taint nodes node1 node-role.kubernetes.io/master:NoSchedule-
#kubectl -n=kube-system scale statefulset px-etcd --replicas=3
