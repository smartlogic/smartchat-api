require 'spec_helper'

describe MediaService do
  let(:friend_ids) { [2, 3] }
  let(:file_path) { Tempfile.new(["file", ".jpg"]).path }
  let(:drawing_path) { Tempfile.new(["drawing", ".jpg"]).path }

  it "should create a media file and send a SQS message for each friend" do
    user = double(:poster, :id => 1)

    notification_service_klass = double(:NotificationService)
    expect(notification_service_klass).to receive(:notify).with(2, anything)
    expect(notification_service_klass).to receive(:notify).with(3, anything)

    AppContainer.stub(:notification_service).and_return(notification_service_klass)

    MediaService.create(user, friend_ids, file_path, drawing_path)

    MediaService::Worker.drain

    expect(Media.count).to eq(2)
    expect(File.exists?(file_path)).to be_false
    expect(File.exists?(drawing_path)).to be_false
  end
end
