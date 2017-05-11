#
# Cookbook Name:: openresty
# Recipe:: default
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
# Author:: Stephen Delano (<stephen@opscode.com>)
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

template '/etc/init.d/nginx' do
  source 'nginx.init.erb'
  owner 'root'
  group 'root'
  mode 00755
  variables(
    :src_binary => node['openresty']['binary'],
    :pid => node['openresty']['pid']
  )
end

defaults_path = value_for_platform_family(
  ['rhel','fedora','amazon','scientific','suse'] => '/etc/sysconfig/nginx',
  'debian' => '/etc/default/nginx'
)

template defaults_path do
  source node['openresty']['service']['defaults_file_template']
  cookbook node['openresty']['service']['defaults_file_cookbook']
  owner 'root'
  group 'root'
  mode 00644
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  if node['openresty']['service']['start_on_boot']
    action [ :enable, :start ]
  end
end
