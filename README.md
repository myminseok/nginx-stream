
# nginx default proxy
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




# compile nginx with stream
tested on ubuntu 14.04, nginx 1.9

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



