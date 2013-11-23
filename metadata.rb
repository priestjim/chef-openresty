name              'openresty'
maintainer        'Panagiotis Papadomitsos'
maintainer_email  'pj@ezgr.net'
license           'Apache 2.0'
description       'Installs and configures the OpenResty NGINX bundle'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md')).chomp
version           IO.read(File.join(File.dirname(__FILE__), 'VERSION')).chomp rescue '0.1.0'

recipe 'openresty', 'Installs the OpenResty NGINX bundle and sets up configuration with Debian apache style sites-enabled/sites-available'

%w{ ubuntu debian centos redhat amazon scientific oracle fedora }.each do |os|
  supports os
end

depends 'build-essential'
depends 'logrotate'
depends 'ohai', '>= 1.1.4'
depends 'yum'
depends 'apt'
depends 'git'

recommends 'postgresql'
recommends 'jemalloc'
