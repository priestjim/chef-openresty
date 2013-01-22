#
# Cookbook Name:: openresty
# Recipe:: default
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Heavily based on Opscode's original nginx cookbook
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

user node['openresty']['user'] do
  system true
  shell '/bin/false'
  home '/var/www'
end

include_recipe 'openresty::ohai_plugin'
include_recipe 'openresty::commons_dir'
include_recipe 'openresty::commons_script'
include_recipe 'build-essential'

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/nginx-#{node['openresty']['source']['version']}.tar.gz"

packages = value_for_platform_family(
  ['rhel','fedora','amazon','scientific'] => [ 'pcre-devel', 'openssl-devel', 'readline-devel', 'ncurses-devel' ],
  'default' => ['libpcre3', 'libpcre3-dev', 'libperl-dev', 'libssl-dev', 'libreadline-dev', 'libncurses5-dev']
)

packages_aio = value_for_platform_family(
    ['rhel','fedora','amazon','scientific'] => [ 'libatomic_ops-devel' ],
    'default' => [ 'libatomic-ops-dev', 'libaio1', 'libaio-dev' ]
)

packages |= packages_aio unless node['kernel']['release'].split('-').first.to_f < 3.0

packages.each do |devpkg|
  package devpkg
end

remote_file node['openresty']['url'] do
  source node['openresty']['url']
  checksum node['openresty']['checksum']
  path src_filepath
  backup false
end

node.run_state['openresty_force_recompile'] = false
node.run_state['openresty_configure_flags'] =
node['openresty']['source']['default_configure_flags'] | node['openresty']['configure_flags']

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

bash 'compile_openresty_source' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} &&
    cd nginx-#{node['openresty']['source']['version']} &&
    ./configure #{node.run_state['openresty_configure_flags'].join(' ')} &&
    make && make install
  EOH

  not_if do
    openresty_force_recompile == false &&
      node.automatic_attrs['openresty'] &&
      node.automatic_attrs['openresty']['version'] == node['openresty']['source']['version'] &&
      node.automatic_attrs['openresty']['configure_arguments'].sort == configure_flags.sort
  end

  notifies :restart, 'service[nginx]'
end

node.run_state.delete('openresty_configure_flags')
node.run_state.delete('openresty_force_recompile')

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :start
end
