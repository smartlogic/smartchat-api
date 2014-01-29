namespace :config do
  desc "Downloads configuration for a specified environment"
  task :download, [:environment] do |_, args|
    environment = args[:environment]

    next unless environment

    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket = s3.buckets["smartchat-config"]
    object = bucket.objects["#{environment}.env"]

    File.open("#{environment}.env", "w") do |file|
      file.write(object.read)
    end
  end

  desc "Uploads new configuration for specified environment"
  task :upload, [:environment] do |_, args|
    environment = args[:environment]

    next unless environment

    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket = s3.buckets["smartchat-config"]
    object = bucket.objects["#{environment}.env"]

    object.write(File.read("#{environment}.env"))
  end
end
