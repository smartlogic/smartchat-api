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

    if Rails.env.development? || Rails.env.all?
      let(:redis) do
        Redis::Namespace.new("smartchat-#{Rails.env}", :redis => Redis.new)
      end
    end

    let(:media_uri) do
      case Rails.env
      when "development"
        URI::HTTP.build(:scheme => "http", :host => ENV["SMARTCHAT_API_HOST"], :port => ENV["SMARTCHAT_API_PORT"].to_i, :path => "/files/")
      when "test"
        URI::HTTP.build(:scheme => "http", :host => "example.com", :path => "/files/")
      when "all"
        URI::HTTP.build(:host => ENV["SMARTCHAT_API_HOST"], :port => ENV["SMARTCHAT_API_PORT"].to_i, :path => "/files/")
      when "production"
        URI::HTTP.build(:scheme => "http", :host => "smartchat.smartlogic.io", :path => "/files/")
      end
    end

    let(:media_store) do
      if Rails.env.development? || Rails.env.all?
        require 'file_media_store'
        path = Pathname.new(ENV["SMARTCHAT_FILE_PATH")
        FileMediaStore.new(path, media_uri, redis)
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
      if Rails.env.development? || Rails.env.all?
        require 'redis_queue'
        RedisQueue.new(redis)
      else
        AWS::SQS.new.queues.named(sqs_queue_name)
      end
    end

    let(:notification_service) do
      NotificationService
    end

    let(:friend_service) do
      FriendService
    end

    let(:clean_up_limit) do
      -> { 2.weeks.ago }
    end

    let(:twilio_account_sid) do
      ENV["TWILIO_ACCOUNT_SID"]
    end

    let(:verification_phone_number) do
      ENV["TWILIO_VERIFICATION_PHONE_NUMBER"]
    end
  end
end
