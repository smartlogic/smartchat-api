require 'aws-sdk'

set :rails_env, "production"

primary = true

ec2 = AWS::EC2.new
ec2.instances.tagged("Type").tagged_values("web").each do |instance|
  next unless instance.status == :running
  server instance.public_dns_name, :web, :app, :db, :primary => primary

  primary = false
end

ec2.instances.tagged("Type").tagged_values("worker").each do |instance|
  next unless instance.status == :running
  server instance.public_dns_name, :worker, :app
end

ec2.instances.tagged("Type").tagged_values("scheduler").each do |instance|
  next unless instance.status == :running
  server instance.public_dns_name, :scheduler, :app
end
