# playstation

projects i need to create to solidify my knowledge of certain skills (preference: use helm/rancher/awx)
1: install and connect etcd to portworx cluster and use it to manage app volumes (status: noincomplete)
issues:
etcdctl member list is not showing the 3 members => working
metallb lb ip addr not connecting to any member
/opt/pwx/bin/pxctl status is not showing the 3 nodes
don't know how to customize portworx helm chart to use a specific disk drive (values.yaml?)
don't know how to customize etcd helm chart to use a specific configuratin (values.yaml?)

2: install teamcity and create and run applications with teamcity agents (status: incomplete)
issues:

3: install rancher and use it manage clusters and deploy apps to k8s cluster (status: incomplete)
issues:

4: install awx and use it to install configurations to remote machines (status: incomplete)
issues:

5: install jenkins and use it to manage multipipeline applications (status: not-started)
6: install nexus and use it to manage image/package repositories (status: not-started)
7: install sonarqube and use it to manage manage code quality (status: not-started)
8: install vault and use it manage application secrets (status: not-started)
9: install prometheus & grafana and use to create data analytical dashboards (status: not-started)
10: install argocd and use to manage application deployment (status: not-started)


********something iface needs to be modified in calico yaml file
workaround
vagrant@etcd-pwx-worker01:~$ sudo -i
root@etcd-pwx-worker01:~# cat > /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=172.40.40.11
root@etcd-pwx-worker01:~# sudo systemctl daemon-reload && sudo systemctl restart kubelet