template "#{node['smartchat']['smartchat_env']}/smartchat_env" do
  source 'smartchat_env.erb'
  owner 'deploy'
  group 'deploy'
  mode '0644'
end
