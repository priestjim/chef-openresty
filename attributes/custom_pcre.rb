#
# Cookbook Name:: openresty
# Attribute:: pcre
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

default['openresty']['pcre']['version']  = '8.37'
default['openresty']['pcre']['url']      = "http://downloads.sourceforge.net/project/pcre/pcre/#{node['openresty']['pcre']['version']}/pcre-#{node['openresty']['pcre']['version']}.tar.bz2"
default['openresty']['pcre']['checksum'] = '51679ea8006ce31379fb0860e46dd86665d864b5020fc9cd19e71260eef4789d'
