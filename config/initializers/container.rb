class AppContainer
  class << self
    def self.let(method, &block)
      define_method(method) do
        @lets ||= {}
        @lets[method] ||= instance_eval(&block)
      end
    end

    let(:sqs_queue_name) do
      "smartchat-#{Rails.env}"
    end

    let(:sqs_queue) do
      AWS::SQS.new.queues.named(sqs_queue_name)
    end

    let(:s3_bucket_name) do
      "smartchat-#{Rails.env}"
    end

    let(:s3_bucket) do
      AWS::S3.new.buckets[s3_bucket_name]
    end
  end
end
