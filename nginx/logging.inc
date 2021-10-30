# Disable some logs:
location = /favicon.ico { access_log off; log_not_found off; }
location = /robots.txt  { access_log off; log_not_found off; }

# Ignore Apple touch icon requests if non existent
location ~ /apple-touch-icon(|-\d+x\d+)(|-precomposed).png {
    try_files $uri =404;
}
