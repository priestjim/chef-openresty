#
# Cookbook Name:: openresty
# Recipe:: cache_purge_module
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2013, Panagiotis Papadomitsos
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

cpm_src_filename = "ngx_cache_purge-#{::File.basename(node['openresty']['cache_purge']['url'])}"
cpm_src_filepath = "#{Chef::Config['file_cache_path']}/#{cpm_src_filename}"
cpm_extract_path = "#{Chef::Config['file_cache_path']}/ngx_cache_purge/#{node['openresty']['cache_purge']['checksum']}"

remote_file cpm_src_filepath do
  source node['openresty']['cache_purge']['url']
  checksum node['openresty']['cache_purge']['checksum']
  owner 'root'
  group 'root'
  mode 00644
end

bash 'extract_cache_purge_module' do
  cwd ::File.dirname(cpm_src_filepath)
  code <<-EOH
    mkdir -p #{cpm_extract_path}
    tar xzf #{cpm_src_filename} -C #{cpm_extract_path}
    mv #{cpm_extract_path}/*/* #{cpm_extract_path}/
  EOH

  not_if { ::File.exists?(cpm_extract_path) }
end

node.run_state['openresty_configure_flags'] |= ["--add-module=#{cpm_extract_path}"]
