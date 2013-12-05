require 'spec_helper'

describe MediaService do
  let(:media_attributes) { {
    :friend_ids => [2, 3],
    :file => File.open(Rails.root.join("spec", "fixtures", "file.png"))
  } }

  it "should create a media file and send a SQS message for each friend" do
    media = double(:media)

    media_klass_double = double(:Media)
    expect(media_klass_double).to receive(:create).
      with(media_attributes.except(:friend_ids).merge(:user_id => 1)).
      and_return(media)

    user = double(:user, :id => 1)

    notification_service_klass = double(:NotificationService)
    expect(notification_service_klass).to receive(:notify).with(2, media)
    expect(notification_service_klass).to receive(:notify).with(3, media)

    MediaService.create(user, media_attributes, media_klass_double, notification_service_klass)
  end
end
