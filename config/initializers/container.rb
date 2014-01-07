$LOAD_PATH.unshift(File.expand_path("../../worker/lib", File.dirname(__FILE__)))
require 's3_media_store'

class AppContainer
  class << self
    def self.let(method, &block)
      define_method(method) do
        @lets ||= {}
        @lets[method] ||= instance_eval(&block)
      end
    end

    let(:media_uri) do
      case Rails.env
      when "development"
        URI::HTTP.build(:scheme => "http", :host => ENV["SMARTCHAT_API_HOST"], :port => 3000, :path => "/files/")
      when "test"
        URI::HTTP.build(:scheme => "http", :host => "example.com", :path => "/files/")
      when "production"
        URI::HTTP.build(:scheme => "http", :host => "smartchat.smartlogic.io", :path => "/files/")
      end
    end

    let(:media_store) do
      if Rails.env.development?
        require 'file_media_store'
        path = Pathname.new(Rails.root.join("tmp", "files"))
        FileMediaStore.new(path, media_uri)
      else
        S3MediaStore.new(s3_private_bucket, s3_published_bucket, media_uri)
      end
    end

    let(:s3_published_bucket_name) do
      "smartchat-#{Rails.env}"
    end

    let(:s3_published_bucket) do
      AWS::S3.new.buckets[s3_published_bucket_name]
    end

    let(:s3_private_bucket_name) do
      "smartchat-private-#{Rails.env}"
    end

    let(:s3_private_bucket) do
      AWS::S3.new.buckets[s3_private_bucket_name]
    end

    let(:sqs_queue_name) do
      "smartchat-#{Rails.env}"
    end

    let(:queue) do
      if Rails.env.development?
        require 'redis_queue'
        RedisQueue.new
      else
        AWS::SQS.new.queues.named(sqs_queue_name)
      end
    end

    let(:notification_service) do
      NotificationService
    end
  end
end
