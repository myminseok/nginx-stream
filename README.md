# nginx with tcp stream
tested on ubuntu 14.04, nginx 1.9

### 1. (as root) install dependencies
https://kx.cloudingenium.com/linux/ubuntu/build-version-nginx/
```
apt list --installed
dpkg -l

apt-get install libpcre3 libpcre3-dev
apt-get install zlib1g-dev
apt-get install openssl
apt-get install libssl-dev

```
### 2. compile and install
```
wget http://nginx.org/download/nginx-1.13.8.tar.gz
tar -xvf nginx-1.11.4.tar.gz
cd nginx-1.11.4

./configure --sbin-path=/usr/sbin --conf-path=/etc/nginx/nginx.conf  --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-threads --with-stream --with-http_slice_module --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log

make 

make install


```
### 3. nginx.conf
vi /etc/nginx/nginx.conf

```
worker_processes 1;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
        worker_connections 768;
        multi_accept on;
}

stream {
    upstream vcenter {
         server 10.10.10.10:443;
    }
    server {
       listen 443 ;
       proxy_pass vcenter;
    }
    server {
       listen 8443;
       proxy_pass 10.10.10.10:9443;
    }
}

```


### 4. test

```
/usr/sbin/nginx
tail -f /var/log/nginx/*
netstat -nlp | grep nginx
```

### 5. register as system service

vi /lib/systemd/system/nginx.service
```
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```


```
systemctl daemon-reload
systemctl restart nginx.service
systemctl status nginx.service

tail -f /var/log/nginx/*

```

==========================

# Iptables forwarding

```
sysctl -a | grep forward
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

sudo vi /etc/sysctl.conf

#uncomment this line
net.ipv4.ip_forward=1

sysctl -p

# eth0 -> eth1
iptables -A FORWARD —in-interface eth0 -j AcCEPT
iptables -t nat -A POSTROUTING —out-interface eth1 -j MASQUERADE

# eth1 -> eth0
iptables -A FORWARD —in-interface eth1 -j AcCEPT
iptables -t nat -A POSTROUTING —out-interface eth0 -j MASQUERADE
```


==========================

# nginx http proxy 
tested on ubuntu 14.04, nginx 1.4.

in browser(client), 301 redirect response url(private network) will be redirect to url that client can access(proxy IP).

## proxy server 192.168.11.226

```
/etc/nginx/nginx.conf
http {
        server {
            listen 8000;
            location / {
                proxy_pass http://10.10.10.2:8000;
                # 301 moved permanently response will be redirected
                proxy_redirect http://10.10.10.2:7000/ http://$host:7000/;
           }
        }
        server {
           listen 7000;
           location / {
                proxy_pass http://10.10.10.2:7000;
           }
        }

}
```
or check /etc/nginx/sites-enabled/default 

## private network server 10.10.10.2

### sample service (redirect)
simple-redirect.py

```
import SimpleHTTPServer
import SocketServer

# Redirect to Google.com
class Redirect(SimpleHTTPServer.SimpleHTTPRequestHandler):
   def do_GET(self):
       print self.path
       self.send_response(301)
       #new_path = '%s%s'%('https://google.com', self.path)
       new_path = '%s%s'%('http://10.10.10.2:7000/.cf', self.path)
       self.send_header('Location', new_path)
       self.end_headers()

# Listen on 127.0.0.1:8000
SocketServer.TCPServer(("10.10.10.2", 8000), Redirect).serve_forever()

```

$ python simple-redirect.py

### sample service (directory listing)
$ python -m SimpleHTTPServer 8000


## test.
in browser(client), 301 redirect response url(private network) will be redirect to url that client can access(proxy IP).

```
curl -v http://192.168.11.226:8000
* Rebuilt URL to: http://192.168.11.226:8000/
*   Trying 192.168.11.226...
* TCP_NODELAY set
* Connected to 192.168.11.226 (192.168.11.226) port 8000 (#0)
> GET / HTTP/1.1
> Host: 192.168.11.226:8000
> User-Agent: curl/7.54.0
> Accept: */*
> 
< HTTP/1.1 301 Moved Permanently
< Server: nginx/1.4.6 (Ubuntu)
< Date: Sat, 13 Jan 2018 03:12:34 GMT
< Transfer-Encoding: chunked
< Connection: keep-alive
< Location: http://192.168.11.226:7000/.cf/


```



