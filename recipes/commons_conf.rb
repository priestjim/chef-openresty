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

kernel_supports_aio = Chef::VersionConstraint.new('>= 2.6.22').include?(node['kernel']['release'].split('-').first)

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

template 'nginx.conf' do
  path "#{node['openresty']['dir']}/nginx.conf"
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables :kernel_supports_aio => kernel_supports_aio
  notifies :reload, node['openresty']['service']['resource']
end

cookbook_file "#{node['openresty']['dir']}/mime.types" do
  source 'mime.types'
  owner 'root'
  group 'root'
  mode 00644
  notifies :reload, node['openresty']['service']['resource']
end

cookbook_file "#{node['openresty']['dir']}/conf.d/general_security.conf.inc" do
  source 'general_security.conf.inc'
  owner 'root'
  group 'root'
  mode 00644
end

if node['openresty']['default_site_enabled']
  template "#{node['openresty']['dir']}/sites-available/default" do
    source 'default-site.erb'
    owner 'root'
    group 'root'
    mode 00644
    if ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/000-default")
      notifies :reload, node['openresty']['service']['resource']
    end
  end

  openresty_site 'default' do
    action :enable
  end
end

if node['openresty']['logrotate']

  include_recipe 'logrotate'

  # Log rotation
  logrotate_app 'openresty' do
    path "#{node['openresty']['log_dir']}/*.log"
    enable true
    frequency 'daily'
    rotate 7
    cookbook 'logrotate'
    create "0644 #{node['openresty']['user']} adm"
    options [ 'missingok', 'delaycompress', 'notifempty', 'compress', 'sharedscripts' ]
    postrotate "[[ ! -f #{node['openresty']['pid']} ]] || kill -USR1 $(cat #{node['openresty']['pid']})"
  end

end
