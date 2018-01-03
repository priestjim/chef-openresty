#
# Cookbook Name:: openresty
# Recipe:: ohai_plugin
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

plugin_path = nil
if node.attribute?('opsworks') then
    plugin_path = node['openresty']['source']['state']

    directory plugin_path do
      owner 'root'
      group 'root'
      mode 00755
      action :nothing
    end.run_action(:create)
end

ohai_plugin 'nginx' do
  source_file 'nginx.rb.erb'
  path(plugin_path) if plugin_path
  compile_time true
  resource :template
  variables(
    :nginx_bin => node['openresty']['binary']
  )
end
