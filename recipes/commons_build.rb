#
# Cookbook Name:: openresty
# Recipe:: default
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
# Author:: Stephen Delano (<stephen@opscode.com>)
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

require 'chef/version_constraint'

kernel_supports_aio = Chef::VersionConstraint.new('>= 2.6.22').include?(node['kernel']['release'].split('-').first)
restart_on_update = node['openresty']['service']['restart_on_update'] ? ' && $( kill -QUIT `pgrep -U root nginx` || true )' : ''

include_recipe 'build-essential'

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/ngx_openresty-#{node['openresty']['source']['version']}.tar.gz"

packages = value_for_platform_family(
  ['rhel','fedora','amazon','scientific'] => [ 'openssl-devel', 'readline-devel', 'ncurses-devel' ],
  'debian' => [ 'libperl-dev', 'libssl-dev', 'libreadline-dev', 'libncurses5-dev']
)

# Enable AIO for newer kernels
packages |= value_for_platform_family(
    ['rhel','fedora','amazon','scientific'] => [ 'libatomic_ops-devel' ],
    'debian' => [ 'libatomic-ops-dev', 'libaio1', 'libaio-dev' ]
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

# Custom PCRE
if node['openresty']['custom_pcre']
  pcre_path = "#{Chef::Config['file_cache_path'] || '/tmp'}/pcre-#{node['openresty']['pcre']['version']}"
  pcre_opts = 'export PCRE_CONF_OPT="--enable-utf8 --enable-unicode-properties" && '
  remote_file "#{pcre_path}.tar.bz2" do
    owner 'root'
    group 'root'
    mode 00644
    source node['openresty']['pcre']['url']
    checksum node['openresty']['pcre']['checksum']
    action :create_if_missing
  end
  execute 'openresty-extract-pcre' do
    user 'root'
    cwd(Chef::Config['file_cache_path'] || '/tmp')
    command "tar xjf #{pcre_path}.tar.bz2"
    not_if { ::File.directory?(pcre_path) }
  end
  node.run_state['openresty_configure_flags'] |= [ "--with-pcre=#{pcre_path}", '--with-pcre-jit' ]
else
  pcre_opts = ''
  value_for_platform_family(
    ['rhel','fedora','amazon','scientific'] => [ 'pcre', 'pcre-devel' ],
    'debian' => ['libpcre3', 'libpcre3-dev' ]
  ).each do |pkg|
    package pkg
  end
  node.run_state['openresty_configure_flags'] |= [ '--with-pcre' ]
end

# System flags
node.run_state['openresty_configure_flags'] |= [ '--with-file-aio', '--with-libatomic' ]  if kernel_supports_aio

# OpenResty extra modules
node.run_state['openresty_configure_flags'] |= [ '--with-luajit' ]                        if node['openresty']['or_modules']['luajit']
node.run_state['openresty_configure_flags'] |= [ '--with-http_iconv_module' ]             if node['openresty']['or_modules']['iconv']

# Jemalloc
if node['openresty']['link_to_jemalloc']
  include_recipe 'jemalloc'
  node.run_state['openresty_configure_flags'] |= [ '--with-ld-opt="-ljemalloc"' ]
end

if node['openresty']['or_modules']['postgres']
  include_recipe 'postgresql::client'
  node.run_state['openresty_configure_flags'] |= [ '--with-http_postgres_module' ]
end

if node['openresty']['or_modules']['drizzle']
  drizzle = value_for_platform_family(
    ['rhel','fedora','amazon','scientific'] => 'libdrizzle-devel',
    'debian' => 'libdrizzle-dev'
  )
  package drizzle
  node.run_state['openresty_configure_flags'] |= [ '--with-http_drizzle_module' ]
end

node['openresty']['modules'].each do |ngx_module|
  include_recipe "openresty::#{ngx_module}"
end

node['openresty']['extra_modules'].each do |ngx_module|
  include_recipe ngx_module
end

configure_flags = node.run_state['openresty_configure_flags']
openresty_force_recompile = node.run_state['openresty_force_recompile']

ruby_block 'persist-openresty-configure-flags' do
  block do
    if Chef::Config[:solo]
      ::File.write(::File.join(::File.dirname(src_filepath), 'openresty.configure-opts'), configure_flags.sort.uniq.join("\n"))
    else
      node.set['openresty']['persisted_configure_flags'] = configure_flags.sort.uniq 
    end
  end
  action :nothing
end

bash 'compile_openresty_source' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} &&
    cd ngx_openresty-#{node['openresty']['source']['version']} &&
    #{pcre_opts}
    ./configure #{node.run_state['openresty_configure_flags'].join(' ')} &&
    make -j#{node['cpu']['total']} && make install #{restart_on_update}
  EOH

  # OpenResty configure args massaging due to the configure script adding its own arguments along our custom ones
  if Chef::Config[:solo]
    not_if do
      openresty_force_recompile == false &&
        node.automatic_attrs['nginx'] &&
        node.automatic_attrs['nginx']['version'] == node['openresty']['source']['version'] &&
        (::File.read(::File.join(:: File.dirname(src_filepath), 'openresty.configure-opts')) || '' rescue '') ==
        configure_flags.sort.uniq.join("\n")
    end
  else
    not_if do
      openresty_force_recompile == false &&
        node.automatic_attrs['nginx'] &&
        node.automatic_attrs['nginx']['version'] == node['openresty']['source']['version'] &&
        node['openresty']['persisted_configure_flags'] &&
        node['openresty']['persisted_configure_flags'] == configure_flags.sort.uniq
    end
  end

  notifies :create, 'ruby_block[persist-openresty-configure-flags]'
  if node['openresty']['restart_on_update']
    notifies :restart, node['openresty']['resource']
  end
end

node.run_state.delete('openresty_configure_flags')
node.run_state.delete('openresty_force_recompile')
