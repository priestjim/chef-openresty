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

kernel_supports_aio = Gem::Version.new(node['kernel']['release'].split('-').first) >= Gem::Version.new('2.6.22')

user node['openresty']['user'] do
  system true
  shell '/bin/false'
  home '/var/www'
end

include_recipe 'openresty::ohai_plugin'
include_recipe 'openresty::commons_dir'
include_recipe 'openresty::commons_script'
include_recipe 'build-essential'

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/ngx_openresty-#{node['openresty']['source']['version']}.tar.gz"

packages = value_for_platform_family(
  ['rhel','fedora','amazon','scientific'] => [ 'pcre-devel', 'openssl-devel', 'readline-devel', 'ncurses-devel' ],
  'default' => ['libpcre3', 'libpcre3-dev', 'libperl-dev', 'libssl-dev', 'libreadline-dev', 'libncurses5-dev']
)

# Enable AIO for newer kernels
packages |= value_for_platform_family(
    ['rhel','fedora','amazon','scientific'] => [ 'libatomic_ops-devel' ],
    'default' => [ 'libatomic-ops-dev', 'libaio1', 'libaio-dev' ]
) if kernel_supports_aio

packages.each do |devpkg|
  package devpkg
end

remote_file node['openresty']['source']['url'] do
  source node['openresty']['source']['url']
  checksum node['openresty']['source']['checksum']
  path src_filepath
  backup false
end

node.run_state['openresty_force_recompile'] = false
node.run_state['openresty_configure_flags'] = node['openresty']['source']['default_configure_flags'] | node['openresty']['configure_flags']

node.run_state['openresty_configure_flags'] |= [ '--with-file-aio', '--with-libatomic' ] if kernel_supports_aio

template '/etc/init.d/nginx' do
  source 'nginx.init.erb'
  owner 'root'
  group 'root'
  mode 00755
  variables(
    :src_binary => node['openresty']['binary'],
    :pid => node['openresty']['pid']
  )
end

defaults_path = case node['platform_family']
  when 'debian'
    '/etc/default/nginx'
  else
    '/etc/sysconfig/nginx'
end

template defaults_path do
  source 'nginx.sysconfig.erb'
  owner 'root'
  group 'root'
  mode 00644
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

include_recipe 'openresty::commons_conf'

node['openresty']['modules'].each do |ngx_module|
  include_recipe "openresty::#{ngx_module}"
end

node['openresty']['extra_modules'].each do |ngx_module|
  include_recipe ngx_module
end

configure_flags = node.run_state['openresty_configure_flags']
openresty_force_recompile = node.run_state['openresty_force_recompile']

# OpenResty configure args massaging due to the configure script adding its own arguments along our custom ones
canonical_configure_args = Array.new
ruby_block "update-openresty-configure-arguments" do
  block do
    canonical_configure_args = node.automatic_attrs['nginx']['configure_arguments'].
      reject{ |f| f =~ /(--add-module=\.\.\/)/ }.
      map{ |f| f =~ /luajit/ ? '--with-luajit' : f }.
      sort
  end
end

bash 'compile_openresty_source' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} &&
    cd ngx_openresty-#{node['openresty']['source']['version']} &&
    ./configure #{node.run_state['openresty_configure_flags'].join(' ')} &&
    make -j#{node['cpu']['total']} && make install
  EOH

  # The current OpenResty implementation does not properly expose the nginx prefix
  not_if do
    openresty_force_recompile == false &&
      node.automatic_attrs['nginx'] &&
      node.automatic_attrs['nginx']['version'] == node['openresty']['source']['version'] &&
      (configure_flags & canonical_configure_args).size == configure_flags.size
  end

  notifies :restart, 'service[nginx]'
end

include_recipe "openresty::commons_cleanup"


node.run_state.delete('openresty_configure_flags')
node.run_state.delete('openresty_force_recompile')

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :start
end
