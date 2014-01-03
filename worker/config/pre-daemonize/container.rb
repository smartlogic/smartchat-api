class AppContainer
  class << self
    def self.let(method, &block)
      define_method(method) do
        @lets ||= {}
        @lets[method] ||= instance_eval(&block)
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
      S3MediaStore.new(s3_private_bucket, s3_published_bucket, media_uri)
    end

    let(:sqs_queue_name) do
      "smartchat-#{DAEMON_ENV}"
    end

    let(:sqs_queue) do
      AWS::SQS.new.queues.named(sqs_queue_name)
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

    let(:gcm_api_key) do
      ENV["GCM_API_KEY"]
    end

    let(:from_address) do
      "dev@smartlogic.io"
    end

    let(:notification_service) do
      NotificationService
    end
  end
end
