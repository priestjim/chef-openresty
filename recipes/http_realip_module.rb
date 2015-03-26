#
# Cookbook Name:: openresty
# Recipe:: http_realip_module
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

# Documentation: http://wiki.nginx.org/HttpRealIpModule

template "#{node['openresty']['dir']}/conf.d/http_realip.conf" do
  source 'modules/http_realip.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    :addresses => node['openresty']['realip']['addresses'],
    :header => node['openresty']['realip']['header']
  )

  if node['openresty']['service']['start_on_boot']
    notifies :reload, node['openresty']['service']['resource']
  end
end

node.run_state['openresty_configure_flags'] |= ['--with-http_realip_module']
