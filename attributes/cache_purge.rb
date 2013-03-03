#
# Cookbook Name:: openresty
# Attribute:: cache_purge
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2013, Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# For more information check out https://github.com/FRiCKLE/ngx_cache_purge
default['openresty']['cache_purge']['version']  = '2.0'
default['openresty']['cache_purge']['url']      = "https://github.com/FRiCKLE/ngx_cache_purge/archive/#{node['openresty']['cache_purge']['version']}.tar.gz"
default['openresty']['cache_purge']['checksum'] = '81f5fd92823752b4037a309928506d426d11f0471f02ee6d6ea9a64f242ec06e'
