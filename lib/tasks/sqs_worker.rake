namespace :worker do
  task :media => [:environment] do
    AppContainer.sqs_queue.poll do |msg|
      puts "Message received"
      body = JSON.parse(msg.body)
      MediaWorker.new.perform(body)
      msg.delete
    end
  end
end
