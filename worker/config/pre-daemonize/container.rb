class AppContainer
  class << self
    def self.let(method, &block)
      define_method(method) do
        @lets ||= {}
        @lets[method] ||= instance_eval(&block)
      end
    end

    if ["development", "all"].include?(DAEMON_ENV)
      let(:redis) do
        Redis::Namespace.new("smartchat-#{DAEMON_ENV}", :redis => Redis.new)
      end
    end

    let(:media_uri) do
      case DAEMON_ENV
      when "development"
        URI::HTTP.build(:host => ENV["SMARTCHAT_API_HOST"], :port => 5000, :path => "/files/")
      when "test"
        URI::HTTP.build(:host => "example.com", :path => "/files/")
      when "all"
        URI::HTTP.build(:host => ENV["SMARTCHAT_API_HOST"], :port => ENV["SMARTCHAT_API_PORT"], :path => "/files/")
      when "production"
        URI::HTTPS.build(:host => "smartchat.smartlogic.io", :path => "/files/")
      end
    end

    let(:media_store) do
      if ["development", "all"].include?(DAEMON_ENV)
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
      if ["development", "all"].include?(DAEMON_ENV)
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

    let(:ios_notifier) do
      IosNotifier
    end

    let(:smartchat_encryptor) do
      SmartchatEncryptor
    end

    let(:gcm_api_key) do
      ENV["GCM_API_KEY"]
    end

    let(:from_address) do
      "dev@smartlogic.io"
    end

    let(:notification_service) do
      NotificationService
    end

    let(:apn_connection) do
      connection = Houston::Client.new
      connection.certificate = File.read(ENV["APN_CERTIFICATE"])
      connection
    end
  end
end
