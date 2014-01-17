require 'spec_helper'

describe CleanUpWorker do
  let(:body) { {
    "user_id" => 1,
    "timestamp" => "2014-01-01"
  } }
  it "should clean up old files" do
    media_store = double(:media_store)
    expect(media_store).to receive(:clean_up_user!).with(1, Time.parse("2014-01-01"))
    container = double(:container, :media_store => media_store)

    CleanUpWorker.new.perform(body, container)
  end
end
