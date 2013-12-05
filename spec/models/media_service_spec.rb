require 'spec_helper'

describe MediaService do
  let(:media_attributes) { {
    :friend_ids => [2],
    :file => File.open(Rails.root.join("spec", "fixtures", "file.png"))
  } }

  it "should create a media file" do
    media_klass_double = double(:Media)
    expect(media_klass_double).to receive(:create).with(media_attributes.except(:friend_ids).merge(:user_id => 1))

    user = double(:user, :id => 1)

    MediaService.create(user, media_attributes, media_klass_double)
  end
end
