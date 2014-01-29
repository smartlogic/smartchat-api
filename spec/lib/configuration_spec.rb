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

  it "should have aws access key id" do
    expect(config.aws_access_key_id).to be_nil
    config.aws_access_key_id = "aws key"
    expect(config.aws_access_key_id).to eq("aws key")
  end

  it "should have aws secret access key" do
    expect(config.aws_secret_access_key).to be_nil
    config.aws_secret_access_key = "aws key"
    expect(config.aws_secret_access_key).to eq("aws key")
  end

  it "should have aws region" do
    expect(config.aws_region).to be_nil
    config.aws_region = "aws region"
    expect(config.aws_region).to eq("aws region")
  end

  it "should have aws smtp username" do
    expect(config.aws_smtp_username).to be_nil
    config.aws_smtp_username = "aws username"
    expect(config.aws_smtp_username).to eq("aws username")
  end

  it "should have aws smtp password" do
    expect(config.aws_smtp_password).to be_nil
    config.aws_smtp_password = "aws password"
    expect(config.aws_smtp_password).to eq("aws password")
  end

  it "should have gcm api key" do
    expect(config.gcm_api_key).to be_nil
    config.gcm_api_key = "gcm api"
    expect(config.gcm_api_key).to eq("gcm api")
  end

  it "should have twilio account sid" do
    expect(config.twilio_account_sid).to be_nil
    config.twilio_account_sid = "account sid"
    expect(config.twilio_account_sid).to eq("account sid")
  end

  it "should have twilio verification phone number" do
    expect(config.twilio_verification_phone_number).to be_nil
    config.twilio_verification_phone_number = "phone number"
    expect(config.twilio_verification_phone_number).to eq("phone number")
  end

  it "should have sidekiq web password" do
    expect(config.sidekiq_web_password).to be_nil
    config.sidekiq_web_password = "sidekiq"
    expect(config.sidekiq_web_password).to eq("sidekiq")
  end

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
