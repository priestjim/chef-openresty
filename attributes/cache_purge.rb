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
default['openresty']['cache_purge']['version']  = '2.3'
default['openresty']['cache_purge']['url']      = "https://codeload.github.com/FRiCKLE/ngx_cache_purge/tar.gz/#{node['openresty']['cache_purge']['version']}"
default['openresty']['cache_purge']['checksum'] = 'cb7d5f22919c613f1f03341a1aeb960965269302e9eb23425ccaabd2f5dcbbec'
