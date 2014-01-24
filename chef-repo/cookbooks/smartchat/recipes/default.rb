package "htop"

rbenv_ruby "2.0.0-p247" do
  global true
end

rbenv_gem "bundler" do
  ruby_version "2.0.0-p247"
end

package "postgresql-server-dev-9.1"

cookbook_file "/etc/syslog.papertrail.crt" do
  source "syslog.papertrail.crt"
  owner "root"
  group "root"
  mode 00644
end

cookbook_file "/etc/rsyslog.conf" do
  source "rsyslog.conf"
  owner "root"
  group "root"
  mode 00644
end

cookbook_file "/etc/rsyslog.d/22-loggly.conf" do
  source "22-loggly.conf"
  owner "root"
  group "root"
  mode 00644
end

package "rsyslog-gnutls"

service "rsyslog" do
  action :restart
end
