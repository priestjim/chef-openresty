#
# Cookbook Name:: openresty
# Provider:: site
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

action :enable do
  timing = [:delayed, :immediately].include?(new_resource.timing) ? new_resource.timing : :delayed
  link_name = (new_resource.name == "default") ? "000-default" : new_resource.name
  a = execute "nxensite #{new_resource.name}" do
    command "/usr/sbin/nxensite #{new_resource.name}"
    notifies :reload, 'service[nginx]', timing
    not_if { ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/#{link_name}") }
  end

  new_resource.updated_by_last_action(a.updated_by_last_action?)
end

action :disable do
  timing = [:delayed, :immediately].include?(new_resource.timing) ? new_resource.timing : :delayed
  link_name = (new_resource.name == "default") ? "000-default" : new_resource.name
  a = execute "nxdissite #{new_resource.name}" do
    command "/usr/sbin/nxdissite #{new_resource.name}"
    notifies :reload, 'service[nginx]', timing
    only_if { ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/#{link_name}") }
  end

  new_resource.updated_by_last_action(a.updated_by_last_action?)    
end
