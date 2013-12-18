require 'spec_helper'

describe MediaWorker do
  let(:created_at) { Time.now }

  let(:media_attributes) { {
    "id" => 3,
    "user_id" => 2,
    "public_key" => "public_key",
    "created_at" => created_at,
    "file_path" => "uploads/media/3/file.png",
    "devices" => [{
      "id" => "a device id",
      "type" => "android"
    }],
    "creator" => {
      "id" => 1,
      "email" => "eric@example.com"
    }
  } }

  it "encrypt and upload the media to the user's s3 folder" do
    file_klass = double(:File)
    expect(file_klass).to receive(:basename).with("uploads/media/3/file.png").and_return("file.png")

    aes = double(:aes, :random_key => "aes key", :random_iv => "aes iv")
    cipher_klass = double(:Cipher)
    expect(cipher_klass).to receive(:new).with("AES-128-CBC").and_return(aes)
    expect(aes).to receive(:encrypt)
    expect(aes).to receive(:update).with("file data").and_return("encrypted data")
    expect(aes).to receive(:final).and_return("")

    rsa = double(:rsa)
    rsa_klass = double(:RSA)
    expect(rsa_klass).to receive(:new).with("public_key").and_return(rsa)
    expect(rsa).to receive(:public_encrypt).with("aes key").and_return("encrypted aes key")
    expect(rsa).to receive(:public_encrypt).with("aes iv").and_return("encrypted aes iv")

    bucket = double(:bucket)
    s3_object = double(:S3Object)

    private_bucket = double(:private_bucket)
    s3_private_object = double(:S3Object_private)

    container = double(:container, :s3_bucket => bucket, :s3_private_bucket => private_bucket)

    expect(bucket).to receive(:objects).and_return({ "users/2/media/3/file.png" => s3_object })
    expect(s3_object).to receive(:write).with("encrypted data")
    expect(s3_object).to receive(:acl=).with(:public_read)

    expect(private_bucket).to receive(:objects).and_return({ "uploads/media/3/file.png" => s3_private_object })
    expect(s3_private_object).to receive(:read).and_return("file data")

    notification_service_klass = double(:NotificationService)
    expect(notification_service_klass).to receive(:send_notification_to_devices).
      with({
        "s3_file_path" => "users/2/media/3/file.png",
        "created_at" => created_at,
        "devices" => [{
          "id" => "a device id",
          "type" => "android"
        }],
        "creator" => {
          "id" => 1,
          "email" => "eric@example.com"
        },
        "encrypted_aes_key" => Base64.strict_encode64("encrypted aes key"),
        "encrypted_aes_iv" => Base64.strict_encode64("encrypted aes iv")
      })

    MediaWorker.new.perform(media_attributes, file_klass, rsa_klass, cipher_klass, notification_service_klass, container)
  end
end
