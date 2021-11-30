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





