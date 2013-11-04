#
# Cookbook Name:: openresty
# Attribute:: luarocks
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2012, Panagiotis Papadomitsos
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

default['openresty']['luarocks']['version']       = '2.1.1'
default['openresty']['luarocks']['url']           = "http://luarocks.org/releases/luarocks-#{node['openresty']['luarocks']['version']}.tar.gz"
default['openresty']['luarocks']['checksum']      = '995ba1b9c982b503fd6fc61c905dc07c3a7533c06587616d9f00d9f62bd318ac'
default['openresty']['luarocks']['default_rocks'] = Hash.new
