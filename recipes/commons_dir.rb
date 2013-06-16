#
# Cookbook Name:: openresty
# Recipe:: commons_dir
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

directory node['openresty']['dir'] do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
end

directory node['openresty']['log_dir'] do
  mode 00755
  owner node['openresty']['user']
  group node['openresty']['group']
  action :create
  recursive true
end

directory node['openresty']['cache_dir'] do
  mode 00755
  owner node['openresty']['user']
  group node['openresty']['group']
  action :create
  recursive true
end

directory '/var/www' do
  owner node['openresty']['user']
  group node['openresty']['group']
  mode 00755
  action :create
end

%w(client_temp proxy_temp fastcgi_temp uwsgi_temp scgi_temp).each do |leaf|
  directory File.join(node['openresty']['cache_dir'], leaf) do
    owner node['openresty']['user']
    group node['openresty']['group']
    mode 00755
    action :create
    recursive true
  end
end

%w(proxy_cache fastcgi_cache uwsgi_cache scgi_cache).each do |leaf|
  directory File.join(node['openresty']['cache_dir'], leaf) do
    owner node['openresty']['user']
    group 'root'
    mode 00750
    action :create
    recursive true
  end
end

%w(sites-available sites-enabled conf.d ssl).each do |leaf|
  directory File.join(node['openresty']['dir'], leaf) do
    owner 'root'
    group 'root'
    mode 00755
  end
end
