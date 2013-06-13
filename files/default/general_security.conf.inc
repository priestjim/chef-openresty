# General security directives, applicable to most configurations

# Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
location ~ /\. {
    deny all;
    log_not_found off;
    access_log off;
}

# Don't log favicon requests or failure to locate the file
location = /favicon.ico {
    log_not_found   off;
    access_log      off;
}

# Don't log robots.txt requests or failure to locate the file
location = /robots.txt {
    allow                       all;
    log_not_found               off;
    access_log                  off;
}
