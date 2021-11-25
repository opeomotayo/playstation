vim /root/awx/installer/inventory
secret_key=awxsecret
admin_user=admin
admin_password=password
pg_username=awx
pg_password=password
pg_database=postgres
awx_alternate_dns_servers="8.8.8.8,8.8.4.4"
postgres_data_dir="/var/lib/awx/pgdocker"
docker_compose_dir="/var/lib/awx/awxcompose"
project_data_dir=/var/lib/awx/projects

#to stop awx going to sleep
sudo sysctl -w net.ipv4.ip_forward=1

vim /var/lib/awx/pgdocker/12/data/pg_hba.conf
host all all 0.0.0.0/0 md5