#!/bin/bash

echo "initialize Kubernetes Cluster"
# for calico
#kubeadm init --apiserver-advertise-address=192.168.60.10 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

# for flannel
kubeadm init --apiserver-advertise-address=192.168.60.10 --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log 2>/dev/null

sleep 60

echo "copy the credentials to your user"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "deploy Flannel network"
su - vagrant -c "kubectl create -f install-k8s/kube-flannel.yaml"

#echo "deploy Calico network"
# su - vagrant -c "kubectl create -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml"

# Generate Cluster join command
echo "generate and save cluster join command to joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh

# # initialize cluster
# kubeadm init --apiserver-advertise-address=192.168.71.11 --pod-network-cidr=10.244.0.0/16
