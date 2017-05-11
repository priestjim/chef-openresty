execute 'systemctl daemon-reload' do
  action :nothing
end

template '/etc/systemd/system/nginx.service' do
  source 'nginx.service.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    :src_binary => node['openresty']['binary'],
    :pid => node['openresty']['pid']
  )
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'nginx' do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
  if node['openresty']['service']['start_on_boot']
    action [ :enable, :start ]
  end
end
