<!-- In case you do not have helm here is the installation procedure, as I will be using helm later on: -->
{
wget https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz;tar -xzvf helm-v3.5.3-linux-amd64.tar.gz;sudo mv linux-amd64/helm /usr/local/bin/helm;
}

<!-- MetalLB: I will be using MetalLB to provide an IP address to an etcd instance. Portworx requires an externally reachable etcd for its kvdb when implemented in a disaggregated architecture.
To install MetalLB: -->
{
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml ;kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml ;
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" ;
}

<!-- I then create and apply the following configmap where a set of available IPs is declared for use by MetalLB. -->
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.80.1-192.168.80.5

<!-- I then apply this to the Kubernetes storage cluster: -->
kubectl -n metallb-system apply -f metallb-cm.yaml


<!-- ETCD CLUSTER: As indicated I need an Etcd instance in order to install Portworx. I will use the bitnami helm chart and local storage from the worker nodes. On each of these workers I create a folder and assign permissions: -->
{
sudo mkdir -p  /data/etcd
sudo chmod 771 /data/etcd
}

apiVersion: v1
kind: PersistentVolume
metadata:
  name: etcd-vol-0
spec:
...

<!-- I can now create my three persistent volume claims using this definition file: -->
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-px-etcd-0
spec:
...

<!-- I create a separate namespace for my Portworx Etcd instance: -->
kubectl create namespace pxetcd

<!-- and then apply the pvc definition file therein: -->


<!-- now add the Bitnami Helm repo and deploy the etcd cluster to the pxectd namespace. Etcd will use the three PVC created in the prior steps: -->

=================
git clone https://github.com/portworx/helm.git

helm upgrade --install portworx --set etcdEndPoint=etcd:http://192.168.80.1:2379,clusterName=local-cluster -f ./helm/charts/portworx/values.yaml  ./helm/charts/portworx --namespace=kube-system
=======================
=================
helm delete --namespace=kube-system px-etcd
kubectl -n kube-system delete -f pvc-etcd.yaml
kubectl delete -f pv-etcd.yaml
sudo rm -rf /data/etcd/data

kubectl apply -f pv-etcd.yaml
kubectl -n kube-system apply -f pvc-etcd.yaml
helm upgrade --install px-etcd bitnami/etcd --version 6.1.1 --set statefulset.replicaCount=3 --set service.type=LoadBalancer --set auth.rbac.enabled=false --namespace=kube-system
kubectl -n=kube-system scale statefulset px-etcd --replicas=3
==========================
********
{
sudo mkdir -p  /data/etcd
sudo chmod 771 /data/etcd
}
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install px-etcd bitnami/etcd --debug --set statefulset.replicaCount=3 --set auth.rbac.enabled=false --set persistence.enabled=true --set persistence.size=1Gi --set image.tag=3.4.15-debian-10-r33 --version 6.2.2 --set image.debug=true --namespace=kube-system 

helm upgrade --install px-etcd bitnami/etcd --debug --set statefulset.replicaCount=3 --set auth.rbac.enabled=false --set persistence.enabled=true --set persistence.size=1Gi --set image.debug=true --namespace=kube-system 

kubectl -n=kube-system scale statefulset px-etcd --replicas=3

kubectl run px-etcd-client --restart='Never' --image docker.io/bitnami/etcd:3.4.15-debian-10-r33 --env ETCDCTL_ENDPOINTS="px-etcd.kube-system.svc.cluster.local:2379" --namespace kube-system --command -- sleep infinity
kubectl exec -it px-etcd-client -n kube-system -- bash

kubectl get svc -l app.kubernetes.io/name=etcd -n=kube-system
curl -L http://10.96.179.243:2379/version -GET -v

git clone https://github.com/portworx/helm.git

helm upgrade --install px-cluster --debug --set etcdEndPoint=etcd:http://10.96.179.243:2379,clusterName=px-cluster  --namespace=kube-system ./helm/charts/portworx/ -f ./helm/charts/portworx/values.yaml

kubectl get pods -n kube-system -l name=portworx

*******


kubectl get po -n=kube-system
kubectl describe po px-etcd-0 -n=kube-system
kubectl get svc -n=kube-system -o wide
curl -L http://10.109.223.132:2379/version -GET -v


helm install etcd bitnami/etcd \
--version 6.2.2 \
--set replicaCount=3 \
--set image.tag=3.4.15-debian-10-r33 \
--set image.debug=true \
--set updateStrategy.type=RollingUpdate \
--set metrics.enabled=true \
--set auth.rbac.enabled=false \
--set disasterRecovery.enabled=true \
--set disasterRecovery.cronjob.schedule='*/10 * * * *' \
--set disasterRecovery.pvc.existingClaim=etcd-snapshot-volume \
--set persistence.enabled=true \
--set persistence.storageClass=rook-ceph-block \
--set persistence.size=1Gi \
--set podAntiAffinity=soft \
--set startFromSnapshot.enabled=true \
--set startFromSnapshot.existingClaim=restore \
--set startFromSnapshot.snapshotFilename=db \
--set initialClusterState=new 

<!-- After a few minutes our etcd is up and running and visible on the assigned LoadBalancer IP by metallb (192.168.1.40): -->
kubectl -n pxetcd get all -o wide

helm install -f stable/prometheus/values.yaml prometheus --name stable/prometheus --namespace prometheus --version 6.7.4
helm install -f stable/prometheus/values.yaml prometheus --name stable/prometheus --namespace prometheus --version 6.7.4


there's no need to modify the etcd ansible file
ref: https://ystatit.medium.com/backup-and-restore-kubernetes-etcd-on-the-same-control-plane-node-20f4e78803cb
**backup
/opt/pwx/bin/pxctl volume create --size=1 --repl=2 --fs=ext4 test-disk1
etcdctl --endpoints=http://192.168.60.11:2379 get "" --prefix --keys-only
etcdctl --endpoints=http://192.168.60.11:2379 member list -w table
etcdctl --endpoints=http://192.168.60.11:2379 snapshot save snapshot.db
etcdctl --endpoints=http://0.0.0.0:2379 snapshot status snapshot.db -w table

**restore
etcdctl snapshot restore snapshot-full.db 
cp -r default.etcd/member/ /var/lib/etcd/
systemctl restart etcd
etcdctl --endpoints=http://192.168.60.11:2379 get "" --prefix --keys-only

docker run --restart=always --name macbook-cluster -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /mnt:/mnt:shared -v /var/cores:/var/cores -v /usr/src:/usr/src portworx/px-enterprise -m team0:0 -d team0

current issues
==============
etcdctl member list is not showing the 3 members
metallb lb ip addr not connecting to any member
/opt/pwx/bin/pxctl status is not showing the 3 nodes
don't know how to customize portworx helm chart to use a specific disk drive (values.yaml?)
don't know how to customize etcd helm chart to use a specific configuratin (values.yaml?)



ETCDCTL_API=3 etcdctl --endpoints=[https://master-1:2379,https://master-2:2370,https://master-3:2379] endpoint health





