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

default['openresty']['pcre']['version']  = '8.35'
default['openresty']['pcre']['url']      = "http://downloads.sourceforge.net/project/pcre/pcre/#{node['openresty']['pcre']['version']}/pcre-#{node['openresty']['pcre']['version']}.tar.bz2"
default['openresty']['pcre']['checksum'] = 'a961c1c78befef263cc130756eeca7b674b4e73a81533293df44e4265236865b'
