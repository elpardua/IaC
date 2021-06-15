#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

amazon-linux-extras enable nginx1
sudo yum clean metadata
sudo yum -y install nginx

# make sure nginx is started
systemctl enable nginx
systemctl start nginx
