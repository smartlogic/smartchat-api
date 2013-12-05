fog_config = {
  "aws_access_key_id"      => ENV['S3_ACCESS_KEY_ID'],
  "aws_secret_access_key"  => ENV['S3_SECRET_ACCESS_KEY']
}

CarrierWave.configure do |config|
  config.storage = :fog

  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => fog_config["aws_access_key_id"],
    :aws_secret_access_key  => fog_config["aws_secret_access_key"],
  }

  config.fog_directory  = "smartchat-#{Rails.env}"
end

if Rails.env.development? || Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end
