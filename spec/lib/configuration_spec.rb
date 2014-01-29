require 'spec_helper'
require 'configuration'

describe Configuration do
  after do
    redis.keys.each do |key|
      redis.del(key)
    end
  end

  let(:redis) { Redis::Namespace.new("smartchat-test:config", Redis.new) }

  let(:config) { Configuration.new(redis) }

  it "should convert to hash for easy inspection" do
    expect(config.to_h).to eq({
      :aws_access_key_id => nil,
      :aws_secret_access_key => nil,
      :aws_region => nil,
      :aws_smtp_username => nil,
      :aws_smtp_password => nil,
      :gcm_api_key => nil,
      :twilio_account_sid => nil,
      :twilio_verification_phone_number => nil,
      :sidekiq_web_password => nil
    })
  end
end
