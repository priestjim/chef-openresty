#
# Cookbook Name:: openresty
# Provider:: site
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

action :enable do

    a = execute "nxensite #{new_resource.name}" do
      command "/usr/sbin/nxensite #{new_resource.name}"
      notifies :reload, 'service[nginx]'
      not_if do ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/#{new_resource.name}") end
    end

    new_resource.updated_by_last_action(a.updated_by_last_action?)
end

action :disable do

    a = execute "nxdissite #{new_resource.name}" do
      command "/usr/sbin/nxdissite #{new_resource.name}"
      notifies :reload, 'service[nginx]'
      only_if do ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/#{new_resource.name}") end
    end

    new_resource.updated_by_last_action(a.updated_by_last_action?)
    
end
