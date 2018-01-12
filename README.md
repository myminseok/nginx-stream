
# compile nginx with stream (ubuntu 14.04)


# as root
https://kx.cloudingenium.com/linux/ubuntu/build-version-nginx/
```
apt list --installed
dpkg -l

apt-get install libpcre3 libpcre3-dev
apt-get install zlib1g-dev
apt-get install openssl
apt-get install libssl-dev


wget http://nginx.org/download/nginx-1.13.8.tar.gz
tar -xvf nginx-1.11.4.tar.gz
cd nginx-1.11.4

./configure --sbin-path=/usr/sbin --conf-path=/etc/nginx/nginx.conf  --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-threads --with-stream --with-http_slice_module --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log

make 
make install

service nginx restart
```

## nginx proxy
```
/etc/nginx/nginx.conf


stream {
    upstream vcenter {
         server 10.10.10.10:443;
    }
    server {
       listen 443 ;
       proxy_pass vcenter;
    }
    server {
       listen 9443;
       proxy_pass 10.10.10.10:9443;
    }
    server {
       listen 5480;
       proxy_pass 10.10.10.10:5480;
    }
}
```

python -m SimpleHTTPServer 8000
