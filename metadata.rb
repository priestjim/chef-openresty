name              'openresty'
maintainer        'Panagiotis Papadomitsos'
maintainer_email  'pj@ezgr.net'
license           'Apache 2.0'
description       'Installs and configures the OpenResty NGINX bundle'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue '0.1.0'

recipe 'openresty', 'Installs openresty package and sets up configuration with Debian apache style with sites-enabled/sites-available'

%w{ ubuntu debian centos redhat amazon scientific oracle fedora }.each do |os|
  supports os
end

%w{ build-essential logrotate }.each do |cb|
  depends cb
end

depends 'ohai', '>= 1.1.4'

%w{ runit bluepill yum }.each do |cb|
  recommends cb
end

attribute 'openresty/dir',
  :display_name => 'OpenResty Directory',
  :description => 'Location of openresty configuration files',
  :default => '/etc/nginx'

attribute 'openresty/log_dir',
  :display_name => 'OpenResty Log Directory',
  :description => 'Location for openresty logs',
  :default => '/var/log/nginx'

attribute 'openresty/user',
  :display_name => 'OpenResty User',
  :description => 'User OpenResty will run as',
  :default => 'www-data'

attribute 'openresty/binary',
  :display_name => 'OpenResty Binary',
  :description => 'Location of the OpenResty server binary',
  :default => '/usr/sbin/nginx'

attribute 'openresty/gzip',
  :display_name => 'OpenResty Gzip',
  :description => 'Whether gzip is enabled',
  :default => 'on'

attribute 'openresty/gzip_http_version',
  :display_name => 'OpenResty Gzip HTTP Version',
  :description => 'Version of HTTP Gzip',
  :default => '1.0'

attribute 'openresty/gzip_comp_level',
  :display_name => 'OpenResty Gzip Compression Level',
  :description => 'Amount of compression to use',
  :default => '2'

attribute 'openresty/gzip_proxied',
  :display_name => 'OpenResty Gzip Proxied',
  :description => 'Whether gzip is proxied',
  :default => 'any'

attribute 'openresty/gzip_types',
  :display_name => 'OpenResty Gzip Types',
  :description => 'Supported MIME-types for gzip',
  :type => 'array',
  :default => [ 'text/plain', 'text/css', 'application/x-javascript', 'text/xml', 'application/xml', 'application/xml+rss', 'text/javascript', 'application/javascript', 'application/json' ]

attribute 'openresty/keepalive',
  :display_name => 'OpenResty Keepalive',
  :description => 'Whether to enable keepalive',
  :default => 'on'

attribute 'openresty/keepalive_timeout',
  :display_name => 'OpenResty Keepalive Timeout',
  :default => '65'

attribute 'openresty/worker_processes',
  :display_name => 'OpenResty Worker Processes',
  :description => 'Number of worker processes',
  :default => '1'

attribute 'openresty/worker_connections',
  :display_name => 'OpenResty Worker Connections',
  :description => 'Number of connections per worker',
  :default => '1024'

attribute 'openresty/server_names_hash_bucket_size',
  :display_name => 'OpenResty Server Names Hash Bucket Size',
  :default => '64'

attribute 'openresty/types_hash_max_size',
  :display_name => 'OpenResty Types Hash Max Size',
  :default => '2048'

attribute 'openresty/types_hash_bucket_size',
  :display_name => 'OpenResty Types Hash Bucket Size',
  :default => '64'

attribute 'openresty/disable_access_log',
  :display_name => 'Disable Access Log',
  :default => 'false'

attribute 'openresty/default_site_enabled',
  :display_name => 'Default site enabled',
  :default => 'true'
