package "htop"

rbenv_ruby "2.0.0-p247" do
  global true
end

rbenv_gem "bundler" do
  ruby_version "2.0.0-p247"
end

package "postgresql-server-dev-9.1"
