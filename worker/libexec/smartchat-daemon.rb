# Generated sqs daemon

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

# IMPORTANT CONFIGURATION NOTES
#
# The aws-sdk gem provides various mechanisms for configuring the
# client libraries. It is recommended that you look at the
# documentation for the most up-to-date or appropriate way of
# configuring it.
#
# At the time of writing, the (aws-sdk) gem will attempt to use
# environment variables or the EC2 metadata service to auto-configure
# itself. If this is not the case, you can pass configuration options
# into DaemonKit::SQS.run which will be passed on to the underlying
# AWS::SQS client. By default, we use the 'config/sqs.yml' file to do
# this configuration.

# Run an event-loop for processing
AppContainer.sqs_queue.poll do |msg|
  DaemonKit.logger.debug "Message received"
  DaemonKit.logger.debug msg.body

  body = JSON.parse(msg.body)

  case body["queue"]
  when "media"
    MediaWorker.new.perform(body)
  else
    DaemonKit.logger.warn "Got a message for an unknown queue"
  end
end
