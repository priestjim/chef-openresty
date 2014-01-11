# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :
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

Vagrant.configure('2') do |config|

  config.berkshelf.enabled = true

  config.vm.provider :virtualbox do |v|
    v.gui = true
  end

  config.vm.box = 'ubuntu-new'
  config.vm.hostname = 'openresty'
  config.vm.network :private_network, ip: '172.16.6.2'

  config.vm.provision :chef_solo do |chef|
    chef.arguments = '-Fdoc'
    chef.json = { 'openresty' => { 'link_to_jemalloc' => true, 'luarocks' => { 'default_rocks' => { 'md5' => '1.1.1' }}}}
    chef.run_list = [
      'recipe[jemalloc::default]',
      'recipe[openresty]',
      'recipe[openresty::luarocks]'
    ]

  end
end
