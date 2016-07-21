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

require 'chef/version_constraint'

kernel_supports_aio = Chef::VersionConstraint.new('>= 2.6.22').include?(node['kernel']['release'].split('-').first.chomp('+'))

if node['openresty']['worker_auto_affinity'] && node['openresty']['worker_processes'] != 'auto'

  affinity_mask = Array.new
  cpupos = 0
  (0...node['openresty']['worker_processes']).each do |worker|
    bitmask = (1 << cpupos).to_s(2)
    bitstring = '0' * (node['cpu']['total'] - bitmask.size) + bitmask.to_s
    affinity_mask << bitstring
    cpupos += 1
    cpupos = 0 if (cpupos == node['cpu']['total'])
  end

  node.default['openresty']['worker_cpu_affinity'] = affinity_mask.join(' ')
end

execute 'openresty generate dhparams' do
  command "openssl dhparam -out #{node['openresty']['dir']}/dhparams.pem 2048"
  creates "#{node['openresty']['dir']}/dhparams.pem"
  action :run
  only_if { node['openresty']['generate_dhparams'] }
  if node['openresty']['service']['start_on_boot']
    notifies :reload, node['openresty']['service']['resource']
  end
end

template 'nginx.conf' do
  path "#{node['openresty']['dir']}/nginx.conf"
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables :kernel_supports_aio => kernel_supports_aio
  if node['openresty']['service']['start_on_boot']
    notifies :reload, node['openresty']['service']['resource']
  end
end

cookbook_file "#{node['openresty']['dir']}/mime.types" do
  source 'mime.types'
  owner 'root'
  group 'root'
  mode 00644
  if node['openresty']['service']['start_on_boot']
    notifies :reload, node['openresty']['service']['resource']
  end
end

cookbook_file "#{node['openresty']['dir']}/conf.d/general_security.conf.inc" do
  source 'general_security.conf.inc'
  owner 'root'
  group 'root'
  mode 00644
end

openresty_site 'default' do
  action :enable
  template 'default-site.erb'
  only_if { node['openresty']['default_site_enabled'] }
end

if node['openresty']['logrotate']

  include_recipe 'logrotate'

  # Log rotation
  logrotate_app 'openresty' do
    path "#{node['openresty']['log_dir']}/*.log"
    enable true
    frequency 'daily'
    rotate node['openresty']['logrotate_days']
    create "0644 #{node['openresty']['user']} adm"
    options node['openresty']['logrotate_options']
    postrotate "test -f #{node['openresty']['pid']} && kill -USR1 $(cat #{node['openresty']['pid']})"
  end

end
