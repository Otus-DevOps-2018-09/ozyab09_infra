git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d 

#deploy puma service
wget https://raw.githubusercontent.com/Otus-DevOps-2018-09/ozyab09_infra/packer-base/packer/files/puma.service -O /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl enable puma.service
systemctl start puma.service
