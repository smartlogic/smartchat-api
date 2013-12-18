class AppContainer
  class << self
    def self.let(method, &block)
      define_method(method) do
        @lets ||= {}
        @lets[method] ||= instance_eval(&block)
      end
    end

    let(:sqs_queue_name) do
      "smartchat-#{DAEMON_ENV}"
    end

    let(:sqs_queue) do
      AWS::SQS.new.queues.named(sqs_queue_name)
    end

    let(:s3_bucket_name) do
      "smartchat-#{DAEMON_ENV}"
    end

    let(:s3_bucket) do
      AWS::S3.new.buckets[s3_bucket_name]
    end

    let(:s3_private_bucket_name) do
      "smartchat-private-#{DAEMON_ENV}"
    end

    let(:s3_private_bucket) do
      AWS::S3.new.buckets[s3_private_bucket_name]
    end

    let(:s3_host) do
      "https://s3.amazonaws.com/#{s3_bucket_name}/"
    end

    let(:android_notifier) do
      AndroidNotifier
    end

    let(:gcm_api_key) do
      ENV["GCM_API_KEY"]
    end
  end
end
