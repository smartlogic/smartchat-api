require 'aws-sdk'
require 'redis'
require 'redis-namespace'
require 'configuration'

class AppContainer
  class << self
    def self.let(method, &block)
      define_method(method) do
        @lets ||= {}
        @lets[method] ||= instance_eval(&block)
      end
    end

    if DAEMON_ENV == "development"
      let(:redis) do
        Redis::Namespace.new("smartchat-development", :redis => Redis.new)
      end
    end

    let(:media_uri) do
      case DAEMON_ENV
      when "development"
        URI::HTTP.build(:scheme => "http", :host => ENV["SMARTCHAT_API_HOST"], :port => 5000, :path => "/files/")
      when "test"
        URI::HTTP.build(:scheme => "http", :host => "example.com", :path => "/files/")
      when "production"
        URI::HTTP.build(:scheme => "http", :host => "smartchat.smartlogic.io", :path => "/files/")
      end
    end

    let(:media_store) do
      if DAEMON_ENV == "development"
        puts "Using files for media store"
        require 'file_media_store'
        path = Pathname.new(File.expand_path("../../../../tmp/files", __FILE__))
        FileMediaStore.new(path, media_uri, redis)
      else
        puts "Using S3 for media store"
        S3MediaStore.new(s3_private_bucket, s3_published_bucket, media_uri)
      end
    end

    let(:sqs_queue_name) do
      "smartchat-#{DAEMON_ENV}"
    end

    let(:queue) do
      if DAEMON_ENV == "development"
        puts "Using Redis Queue"
        require 'redis_queue'
        RedisQueue.new(redis)
      else
        puts "Using SQS Queue"
        AWS::SQS.new.queues.named(sqs_queue_name)
      end
    end

    let(:s3_published_bucket_name) do
      "smartchat-#{DAEMON_ENV}"
    end

    let(:s3_published_bucket) do
      AWS::S3.new.buckets[s3_published_bucket_name]
    end

    let(:s3_private_bucket_name) do
      "smartchat-private-#{DAEMON_ENV}"
    end

    let(:s3_private_bucket) do
      AWS::S3.new.buckets[s3_private_bucket_name]
    end

    let(:s3_host) do
      "https://s3.amazonaws.com/#{s3_published_bucket_name}/"
    end

    let(:android_notifier) do
      AndroidNotifier
    end

    let(:smartchat_encryptor) do
      SmartchatEncryptor
    end

    let(:config) do
      redis_yaml = YAML.load(File.read(File.expand_path("../../../../config/redis.yml", __FILE__)))[DAEMON_ENV]
      config_redis = Redis::Namespace.new("smartchat:config", :redis => Redis.new(redis_yaml))
      Configuration.new(config_redis)
    end

    let(:gcm_api_key) do
      config.gcm_api_key
    end

    let(:from_address) do
      "dev@smartlogic.io"
    end

    let(:notification_service) do
      NotificationService
    end
  end
end

AWS.config({
  access_key_id: AppContainer.config.aws_access_key_id,
  secret_access_key: AppContainer.config.aws_secret_access_key,
  region: AppContainer.config.aws_region
})
