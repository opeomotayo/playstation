#!/bin/bash

echo "install utilities"
yum -y install epel-release

echo "add hosts entries"
cat << EOF >> /etc/hosts
# my k8s
192.168.60.10  kmaster.com kmaster
192.168.60.11  kworker1.com kworker1
192.168.60.12  kworker2.com kworker2
192.168.60.13  kworker3.com kworker3

EOF

echo "install docker"
yum install -y -q yum-utils device-mapper-persistent-data lvm2 > /dev/null 2>&1
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce docker-ce-cli containerd.io

echo "enable docker and start it"
sudo usermod -aG docker $USER
systemctl enable docker
systemctl start docker

echo "se recommended systemd as native cgroup driver"
cat << EOF >  /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

EOF

systemctl restart docker

echo "disable SELinux (sadly enough, until support is added)"
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
systemctl disable firewalld
systemctl stop firewalld

sed -i '/swap/d' /etc/fstab
swapoff -a

echo "enable bridge-nf-call-iptables for ipv4 and ipv6"
cat << EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

EOF
sysctl --system

echo "add repo and install kubeadm"

cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*

EOF

echo "install kubelet, kubeadm and kubectl"
yum install -y kubeadm-1.21.1-0 kubelet-1.21.1-0 kubectl-1.21.1-0 --disableexcludes=kubernetes
systemctl daemon-reload && sudo systemctl restart kubelet

echo "enable kubelet"
systemctl enable kubelet

echo "enable bash completion for both"
kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl

echo "activate the completion"
. /etc/profile

yum -y install wget tree

echo "enable ssh password authentication"
echo "[TASK 11] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

echo "set Root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# useradd ansible
# usermod -aG wheel ansible
# echo "ansible" | passwd --stdin ansible >/dev/null 2>&1

# echo "update vagrant user's bashrc file"
# echo "export TERM=xterm" >> /etc/bashrc
