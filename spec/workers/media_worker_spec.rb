require 'spec_helper'

describe MediaWorker do
  let(:created_at) { Time.now }

  let(:media_attributes) { {
    "id" => 3,
    "user_id" => 2,
    "public_key" => "public_key",
    "created_at" => created_at,
    "file_path" => "/path/to/file.png",
    "creator" => {
      "id" => 1,
      "email" => "eric@example.com"
    }
  } }

  it "encrypt and upload the media to the user's s3 folder" do
    # create notification with s3 url
    # send push notification of new notification

    file_klass = double(:File, :read => "file data")
    expect(file_klass).to receive(:basename).with("/path/to/file.png").and_return("file.png")

    rsa = double(:rsa)
    rsa_klass = double(:RSA)
    expect(rsa_klass).to receive(:new).with("public_key").and_return(rsa)
    expect(rsa).to receive(:public_encrypt).with("file data").and_return("encrypted data")

    bucket = double(:bucket)
    s3_object = double(:S3Object)
    container = double(:container, :s3_bucket => bucket)

    expect(bucket).to receive(:objects).and_return({ "users/2/media/3/file.png" => s3_object })
    expect(s3_object).to receive(:write).with("encrypted data")

    notification_service_klass = double(:NotificationService)
    expect(notification_service_klass).to receive(:create).with({
      :s3_file_path => "users/2/media/3/file.png",
      :created_at => created_at,
      :user_id => 2,
      :creator_id => 1
    })

    MediaWorker.new.perform(media_attributes, file_klass, rsa_klass, notification_service_klass, container)
  end
end
