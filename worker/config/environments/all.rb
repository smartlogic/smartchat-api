# This is the same context as the environment.rb file, it is only
# loaded afterwards and only in the production environment

# Change the production log level to debug
#config.log_level = :debug

require 'syslog/logger'
DaemonKit.logger = Syslog::Logger.new("worker")

require 'mail'

Mail.defaults do
  delivery_method(:smtp, {
    :address => 'email-smtp.us-east-1.amazonaws.com',
    :port => '587',
    :user_name => ENV["AWS_SMTP_USERNAME"],
    :password => ENV["AWS_SMTP_PASSWORD"],
    :authentication => :plain,
    :enable_starttls_auto => true
  })
end
