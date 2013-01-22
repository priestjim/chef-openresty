#
# Cookbook Name:: openresty
# Recipe:: commons_dir
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2012, Panagiotis Papadomitsos
# Copyright 2008-2012, Opscode, Inc.
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
  action :create
  recursive true
end

directory node['openresty']['cache_dir'] do
  mode 00755
  owner node['openresty']['user']
  action :create
  recursive true
end

%w(client_temp proxy_temp fastcgi_temp uwsgi_temp scgi_temp).each do |leaf|
  directory File.join(node['openresty']['cache_dir'], leaf) do
    owner node['openresty']['user']
    mode 00755
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
