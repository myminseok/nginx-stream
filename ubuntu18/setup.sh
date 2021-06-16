mkdir -p /etc/nginx
cp ./etc/nginx/nginx.conf /etc/nginx/
cp ./lib/systemd/system/nginx.service /lib/systemd/system/
cp ./usr/sbin/nginx /usr/sbin/
mkdir -p /var/log/nginx
systemctl daemon-reload
systemctl restart nginx
systemctl status nginx
