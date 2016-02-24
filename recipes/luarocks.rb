#
# Cookbook Name:: openresty
# Recipe:: luarocks
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

# Make sure we build with LUAJIT
node.override['openresty']['or_modules']['luajit'] = true
include_recipe 'openresty'

# Install needed packages
%w{ zip unzip }.each do |pkg|
  package pkg
end

src_basename  = ::File.basename(node['openresty']['luarocks']['url'])
src_filepath  = node['openresty']['source']['path']
src_filename  = ::File.basename(src_basename, '.tar.gz')

remote_file "#{src_filepath}/#{src_basename}" do
  source node['openresty']['luarocks']['url']
  checksum node['openresty']['luarocks']['checksum']
  backup false
end

directory File.join(src_filepath, src_filename) do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
end

execute 'extract-openresty-luarocks' do
  command "tar -C #{src_filepath}/#{src_filename} --strip-components=1 -xzf #{src_filepath}/#{src_basename}"
  cwd src_filepath
  action :run
  not_if { ::File.directory?("#{src_filepath}/#{src_filename}") && !Dir["#{src_filepath}/#{src_filename}/*"].empty? }
end

bash 'compile-openresty-luarocks' do
  cwd "#{src_filepath}/#{src_filename}"
  code %Q{./configure --prefix=#{node['openresty']['source']['prefix']}/luajit \\
      --with-lua=#{node['openresty']['source']['prefix']}/luajit \\
      --lua-suffix=jit \\
      --with-lua-include=#{node['openresty']['source']['prefix']}/luajit/include/luajit-2.1 && \\
      make build}
  not_if { ::File.exists?("#{src_filepath}/#{src_filename}/config.unix") && ::File.exists?("#{src_filepath}/#{src_filename}/src/bin/luarocks") }
  action :run
end

execute 'install-openresty-luarocks' do
  command 'make install'
  cwd "#{src_filepath}/#{src_filename}"
  not_if { ::FileUtils.cmp("#{src_filepath}/#{src_filename}/src/bin/luarocks", "#{node['openresty']['source']['prefix']}/luajit/bin/luarocks") rescue false }
  action :run
end

node['openresty']['luarocks']['default_rocks'].each do |rock, version|
  openresty_luarock rock do
    version version
    action :install
  end
end
