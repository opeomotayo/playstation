mkdir /rancher
docker run -d --restart=unless-stopped --privileged -p 80:80 -p 443:443 -v /rancher:/var/lib/rancher rancher/rancher:latest
$ sudo docker run --privileged -d --restart=unless-stopped -v /opt/rancher:/var/lib/rancher -p 80:80 -p 443:443 rancher/rancher