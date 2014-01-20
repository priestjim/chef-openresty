#
# Cookbook Name:: openresty
# Recipe:: http_stub_status_module
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

# The status module can be included in any vhost needed, explicitly, using the include directive

template 'openresty_status' do
  path "#{node['openresty']['dir']}/conf.d/nginx_status.conf.inc"
  source 'modules/nginx_status.conf.inc.erb'
  owner 'root'
  group 'root'
  mode 00644
  if node['openresty']['service']['start_on_boot']
    notifies :reload, node['openresty']['service']['resource']
  end
end

node.run_state['openresty_configure_flags'] |= ['--with-http_stub_status_module']
