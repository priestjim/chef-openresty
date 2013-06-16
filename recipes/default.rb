#
# Cookbook Name:: openresty
# Recipe:: default
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

include_recipe 'openresty::ohai_plugin'
include_recipe 'openresty::commons_user'
include_recipe 'openresty::commons_dir'
include_recipe 'openresty::commons_script'
include_recipe 'openresty::commons_build'
include_recipe 'openresty::commons_conf'
include_recipe 'openresty::commons_cleanup'
if node['openresty']['service']['recipe']
  include_recipe(node['openresty']['service']['recipe'])
end
