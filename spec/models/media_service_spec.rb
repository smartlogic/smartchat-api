require 'spec_helper'

describe MediaService do
  let(:friend_ids) { [2, 3, 4] }
  let(:file_path) { Tempfile.new(["file", ".jpg"]).path }
  let(:drawing_path) { Tempfile.new(["drawing", ".jpg"]).path }

  it "should create a media file and send a SQS message for each friend" do
    user = double(:poster, :id => 1, :username => "eric")

    friend_service = double(:FriendService)
    expect(friend_service).to receive(:friends_with_user?).with(2, 1).and_return(true)
    expect(friend_service).to receive(:friends_with_user?).with(3, 1).and_return(true)
    expect(friend_service).to receive(:friends_with_user?).with(4, 1).and_return(false)

    notification_service = double(:NotificationService)
    expect(notification_service).to receive(:notify).with(2, {
      "poster_id" => 1,
      "poster_username" => "eric",
      "file" => "file.png",
      "drawing" => "drawing.png",
      "created_at" => anything
    })
    expect(notification_service).to receive(:notify).with(3, {
      "poster_id" => 1,
      "poster_username" => "eric",
      "file" => "file.png",
      "drawing" => "drawing.png",
      "created_at" => anything
    })

    media_store = double(:media_store)
    expect(media_store).to receive(:store).with(file_path).
      and_return("file.png").exactly(2).times
    expect(media_store).to receive(:store).with(drawing_path).
      and_return("drawing.png").exactly(2).times

    AppContainer.stub(:friend_service).and_return(friend_service)
    AppContainer.stub(:notification_service).and_return(notification_service)
    AppContainer.stub(:media_store).and_return(media_store)

    MediaService.create(user, friend_ids, file_path, drawing_path)

    MediaService::Worker.drain

    expect(File.exists?(file_path)).to be_false
    expect(File.exists?(drawing_path)).to be_false
  end
end
