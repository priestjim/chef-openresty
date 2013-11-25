#
# Cookbook Name:: openresty
# Recipe:: fair_module
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright (C) 2012 Panagiotis Papadomitsos
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

include_recipe 'git'

module_path = "#{Chef::Config['file_cache_path']}/#{node['openresty']['fair']['name']}"

git module_path do
  repository node['openresty']['fair']['url']
  reference 'master'
  action :checkout
  not_if { ::File.exists?(module_path) }
end

node.run_state['openresty_configure_flags'] |= ["--add-module=#{module_path}"]
