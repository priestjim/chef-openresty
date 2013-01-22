#
# Cookbook Name:: openresty
# Attribute:: default
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2012, Panagiotis Papadomitsos
# Based heavily on Opscode's original nginx cookbook (https://github.com/opscode-cookbooks/nginx)
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# In order to update the version, the checksum attribute should be
# changed too. It is in the source.rb file, though we recommend
# overriding attributes by modifying a role, or the node itself.
# default['openresty']['source']['checksum']

# Download data
default['openresty']['source']['version']   = '1.2.6.1'
default['openresty']['source']['url']       = "http://agentzh.org/misc/nginx/ngx_openresty-#{node['openresty']['source']['version']}.tar.gz"
default['openresty']['source']['checksum']  = '1675b33c9880dd1654cb0aa8604df0bb43de7d7092a5de9fc8e9a6cd774f7d32'

# Directories
default['openresty']['dir']                 = '/etc/nginx'
default['openresty']['log_dir']             = '/var/log/nginx'
default['openresty']['cache_dir']           = '/var/cache/nginx'
default['openresty']['run_dir']             = '/var/run'
default['openresty']['binary']              = '/usr/sbin/nginx'
default['openresty']['pid']                 = "#{node['openresty']['run_dir']}/nginx.pid"

# Namespaced attributes in order not to clash with the OHAI plugin
default['openresty']['source']['conf_path'] = "#{node['openresty']['dir']}/nginx.conf"
default['openresty']['source']['prefix']    = '/usr/share'

# Configure flags
default['openresty']['source']['default_configure_flags'] = [
  "--prefix=#{node['openresty']['source']['prefix']}",
  "--conf-path=#{node['openresty']['source']['conf_path']}",
  "--sbin-path=#{node['openresty']['binary']}",
  "--error-log-path=#{node['openresty']['log_dir']}/error.log",
  "--http-log-path=#{node['openresty']['log_dir']}/access.log",
  "--pid-path=#{node['openresty']['pid']}",
  "--lock-path=#{node['openresty']['run_dir']}/nginx.lock",
  "--http-client-body-temp-path=#{node['openresty']['cache_dir']}/client_temp",
  "--http-proxy-temp-path=#{node['openresty']['cache_dir']}/proxy_temp",
  "--http-fastcgi-temp-path=#{node['openresty']['cache_dir']}/fastcgi_temp",
  "--http-uwsgi-temp-path=#{node['openresty']['cache_dir']}/uwsgi_temp",
  "--http-scgi-temp-path=#{node['openresty']['cache_dir']}/scgi_temp",
  '--with-md5-asm',
  '--with-sha1-asm',
  '--with-pcre-jit',
  '--with-pcre',
  '--with-luajit',
  '--without-http_ssi_module',
  '--without-mail_smtp_module',
  '--without-mail_imap_module',
  '--without-mail_pop3_module'
]

default['openresty']['modules']         = [
  'http_ssl_module',
  'http_gzip_static_module',
  'http_stub_status_module',
  'http_secure_link_module',
  'http_realip_module',
  'http_flv_module',
  'http_mp4_module',
  'fair_module'
]

default['openresty']['extra_modules']   = []
default['openresty']['configure_flags'] = Array.new

# Configuration options
case node['platform_family']
when 'debian'
  default['openresty']['user']        = 'www-data'
when 'rhel', 'scientific', 'amazon', 'oracle', 'fedora'
  default['openresty']['user']        = 'nginx'
else
  default['openresty']['user']        = 'www-data'
end

default['openresty']['group']         = node['openresty']['user']

if node['network']['interfaces']['lo']['addresses'].include?('::1')
  default['openresty']['ipv6'] = true
else
  default['openresty']['ipv6'] = false
end

default['openresty']['gzip']              = 'on'
default['openresty']['gzip_http_version'] = '1.0'
default['openresty']['gzip_comp_level']   = '2'
default['openresty']['gzip_proxied']      = 'any'
default['openresty']['gzip_vary']         = 'off'
default['openresty']['gzip_buffers']      = nil
default['openresty']['gzip_types']        = [
  'text/plain',
  'text/css',
  'application/x-javascript',
  'text/xml',
  'application/xml',
  'application/xml+rss',
  'text/javascript',
  'application/javascript',
  'application/json',
  'font/truetype',
  'font/opentype',
  'application/vnd.ms-fontobject',
  'image/svg+xml'
]

default['openresty']['keepalive']                     = 'on'
default['openresty']['keepalive_timeout']             = 5
default['openresty']['worker_processes']              = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['openresty']['worker_connections']            = 4096
default['openresty']['worker_rlimit_nofile']          = nil
default['openresty']['open_files']                    = 16384
default['openresty']['multi_accept']                  = false
if node['os'].eql?('linux') && node['kernel']['release'].to_f >= 2.6
  default['openresty']['event']                       = 'epoll'
else
  default['openresty']['event']                       = nil
end

default['openresty']['server_names_hash_bucket_size'] = 64
default['openresty']['client_max_body_size']          = '32M'
default['openresty']['client_body_buffer_size']       = '8K'
default['openresty']['large_client_header_buffers']   = '32 32k'

# Open file cache
default['openresty']['open_file_cache'] = {
  'max' => 1000,
  'inactive' => '20s',
  'valid' => '30s',
  'min_uses' => '8',
  'errors' => 'on'
}

default['openresty']['logrotate']                     = true
default['openresty']['disable_access_log']            = true
default['openresty']['default_site_enabled']          = false
default['openresty']['types_hash_max_size']           = 2048
default['openresty']['types_hash_bucket_size']        = 64
