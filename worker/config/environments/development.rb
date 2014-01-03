# This is the same context as the environment.rb file, it is only
# loaded afterwards and only in the development environment

$stdout.sync = true

require 'mail'

Mail.defaults do
  delivery_method :smtp, { :address => 'localhost', :port => '1025' }
end
