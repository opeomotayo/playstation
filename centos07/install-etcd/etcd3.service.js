[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/local/bin/etcd \
		--name {{ inventory_hostname }} \
		--data-dir /var/lib/etcd \
		--quota-backend-bytes 8589934592 \
		--auto-compaction-retention 3 \
		--listen-client-urls http://{{ hostvars[inventory_hostname]['ansible_facts']['eth1']['ipv4']['address'] }}:2379,http://127.0.0.1:2379 \
		--advertise-client-urls http://{{ hostvars[inventory_hostname]['ansible_facts']['eth1']['ipv4']['address'] }}:2379 \
		--listen-peer-urls http://{{ hostvars[inventory_hostname]['ansible_facts']['eth1']['ipv4']['address'] }}:2380,http://127.0.0.1:2380 \
		--initial-advertise-peer-urls http://{{ hostvars[inventory_hostname]['ansible_facts']['eth1']['ipv4']['address'] }}:2380 \
		--initial-cluster-token my-etcd-token \
		--initial-cluster-state new \
		--initial-cluster {% for host in groups['kworkers'] %}{{ hostvars[host]['ansible_facts']['hostname'] }}=http://{{ hostvars[host]['ansible_facts']['eth1']['ipv4']['address'] }}:2380{% if not loop.last %},{% endif %}{% endfor %}

[Install]
WantedBy=multi-user.target