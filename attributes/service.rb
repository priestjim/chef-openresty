#
# Cookbook Name:: openresty
# Attribute:: service
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

# Service recipe for inclusion (can be extra-cookbook)
default['openresty']['service']['recipe']             = 'openresty::service_init'
# Service resource handler - used for notifications
default['openresty']['service']['resource']           = 'service[nginx]'
# Restart automatically after version update
default['openresty']['service']['restart_on_update']  = true
# Start on system boot
default['openresty']['service']['start_on_boot']      = true
