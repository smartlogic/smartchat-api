# This is the same context as the environment.rb file, it is only
# loaded afterwards and only in the test environment

require 'mail'

Mail.defaults do
  delivery_method :test
end
