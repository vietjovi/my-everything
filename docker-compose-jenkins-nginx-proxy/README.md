Run a Jenkins LTS behind a Nginx Reverse Proxy with HTTPS  

**REMEMBER replace the self-signed SSL/TLS certificate with your certificate**  
How to create a self-signed SSL/TLS certificate:  
```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout nginx/cert/nginx-selfsigned.key -out nginx/cert/nginx-selfsigned.crt
```
