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

case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel', 'amazon'
  include_recipe 'yum'
end

kernel_supports_aio = Chef::VersionConstraint.new('>= 2.6.22').include?(node['kernel']['release'].split('-').first.chomp('+'))

include_recipe 'build-essential'

directory node['openresty']['source']['path'] do
  action :create
  recursive true
end

directory node['openresty']['source']['state'] do
  owner 'root'
  group 'root'
  mode 00755
  action :nothing
  only_if { (! Chef::Config[:chef_server_url]) || (Chef::Config[:chef_server_url].include?('chefzero')) }
end.run_action(:create)

# use vars for these for delayed interpolation
src_file_name=node['openresty']['source']['name'] % { file_prefix: node['openresty']['source']['file_prefix'], version: node['openresty']['source']['version'] }
src_file_url=node['openresty']['source']['url'] % { name: src_file_name }
src_filepath  = "#{node['openresty']['source']['path']}/#{src_file_name}.tar.gz"


packages = value_for_platform_family(
  ['rhel','fedora','amazon','scientific'] => ['openssl-devel', 'readline-devel', 'ncurses-devel', 'bzip2'],
  'suse' => ['libopenssl-devel', 'readline-devel', 'ncurses-devel', 'bzip2'],
  'debian' => ['libperl-dev', 'libssl-dev', 'libreadline-dev', 'libncurses5-dev', 'bzip2']
)

# Enable AIO for newer kernels
packages |= value_for_platform_family(
    ['rhel','fedora','amazon','scientific','suse'] => [ 'libatomic_ops-devel' ],
    'debian' => [ 'libatomic-ops-dev', 'libaio1', 'libaio-dev' ]
) if kernel_supports_aio

package packages do
  action :nothing
end.run_action(:install)

remote_file src_file_url do
  source src_file_url
  checksum node['openresty']['source']['checksum']
  path src_filepath
  backup false
end

node.run_state['openresty_force_recompile'] = false
node.run_state['openresty_configure_flags'] = node['openresty']['source']['default_configure_flags'] | node['openresty']['configure_flags']

# Custom PCRE
if node['openresty']['custom_pcre']
  pcre_path = "#{node['openresty']['source']['path'] }/pcre-#{node['openresty']['pcre']['version']}"
  pcre_opts = 'export PCRE_CONF_OPT="--enable-utf" && '
  remote_file "#{pcre_path}.tar.bz2" do
    owner 'root'
    group 'root'
    mode 00644
    source node['openresty']['pcre']['url']
    checksum node['openresty']['pcre']['checksum']
    action :create
  end
  execute 'openresty-extract-pcre' do
    user 'root'
    cwd(node['openresty']['source']['path'] )
    command "tar xjf #{pcre_path}.tar.bz2"
    not_if { ::File.directory?(pcre_path) }
  end
  node.run_state['openresty_configure_flags'] |= [ "--with-pcre=#{pcre_path}", '--with-pcre-conf-opt=--enable-utf', '--with-pcre-jit' ]
else
  pcre_opts = ''
  value_for_platform_family(
    ['rhel','fedora','amazon','scientific','suse'] => [ 'pcre', 'pcre-devel' ],
    'debian' => ['libpcre3', 'libpcre3-dev' ]
  ).each do |pkg|
    package pkg
  end
  node.run_state['openresty_configure_flags'] |= [ '--with-pcre' ]
end

# Custom subrequests
subrequests_file = ::File.join(
  ::File.dirname(src_filepath),
  src_file_name,
  'bundle',
  "nginx-#{node['openresty']['source']['version'].split('.').first(3).join('.')}",
  'src', 'http', 'ngx_http_request.h')

if ::File.exists?(subrequests_file)
  subrequests_configured = ::File.read(subrequests_file).split("\n").grep(/NGX_HTTP_MAX_SUBREQUESTS/).first.split(/\s+/)[2].to_i
else
  subrequests_configured = node['openresty']['max_subrequests']
end

subreq_opts = %Q{sed -ri 's/#define NGX_HTTP_MAX_SUBREQUESTS\\s+[0-9]+$/#define NGX_HTTP_MAX_SUBREQUESTS #{node['openresty']['max_subrequests']}/g' #{subrequests_file} &&}
if subrequests_configured != node['openresty']['max_subrequests']
  Chef::Log.info("OpenResty will be reconfigured for #{node['openresty']['max_subrequests']} maximum subrequests (previously it was at #{subrequests_configured})")
  node.run_state['openresty_force_recompile'] = true
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
    ['rhel','fedora','amazon','scientific','suse'] => 'libdrizzle-devel',
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
    if (! Chef::Config[:chef_server_url]) || (Chef::Config[:chef_server_url].include?('chefzero')) then
      require 'fileutils'
      ::FileUtils.mkdir_p(node['openresty']['source']['state'])
      ::File.write(::File.join(node['openresty']['source']['state'], 'openresty.configure-opts'), configure_flags.sort.uniq.join("\n"))
    else
      node.normal['openresty']['persisted_configure_flags'] = configure_flags.sort.uniq
    end
  end
  action :nothing
end

bash 'compile_openresty_source' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} &&
    cd #{src_file_name} &&
    #{subreq_opts}
    #{pcre_opts}
    ./configure #{node.run_state['openresty_configure_flags'].join(' ')} &&
    make -j#{node['cpu']['total']} && make install
  EOH

  # OpenResty configure args massaging due to the configure script adding its own arguments along our custom ones
  if Chef::Config[:solo]
    not_if do
      openresty_force_recompile == false &&
        node.automatic_attrs['nginx'] &&
        node.automatic_attrs['nginx']['version'] == node['openresty']['source']['version'] &&
        (::File.read(::File.join(node['openresty']['source']['state'], 'openresty.configure-opts')) || '' rescue '') ==
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
  if node['openresty']['service']['restart_on_update']
    notifies :restart, node['openresty']['service']['resource']
  end
end

link ::File.join(node['openresty']['source']['prefix'], 'luajit', 'bin', 'luajit') do
  to ::File.join(node['openresty']['source']['prefix'], 'luajit', 'bin', "luajit-#{node['openresty']['or_modules']['luajit_binary']}")
  only_if do
    node['openresty']['or_modules']['luajit'] &&
    ::File.exists?(::File.join(node['openresty']['source']['prefix'], 'luajit', 'bin', "luajit-#{node['openresty']['or_modules']['luajit_binary']}"))
  end
end

node.run_state.delete('openresty_configure_flags')
node.run_state.delete('openresty_force_recompile')
