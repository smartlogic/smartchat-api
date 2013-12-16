CarrierWave.configure do |config|
  config.storage = :fog

  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
  }

  config.fog_directory  = "smartchat-private-#{Rails.env}"
end

if Rails.env.development? || Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end
