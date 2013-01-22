#
# Cookbook Name:: openresty
# Recipe:: commons_conf
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

kernel_supports_aio = Gem::Version.new(node['kernel']['release'].split('-').first) >= Gem::Version.new('2.6.22')

template 'nginx.conf' do
  path "#{node['openresty']['dir']}/nginx.conf"
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables :kernel_supports_aio => kernel_supports_aio
  notifies :reload, 'service[nginx]'
end

cookbook_file "#{node['openresty']['dir']}/mime.types" do
  source 'mime.types'
  owner 'root'
  group 'root'
  mode 00644
  notifies :reload, 'service[nginx]'
end

template "#{node['openresty']['dir']}/sites-available/default" do
  source 'default-site.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :reload, 'service[nginx]'
end

nginx_site 'default' do
  enable node['openresty']['default_site_enabled']
end
