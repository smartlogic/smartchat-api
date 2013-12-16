require 'spec_helper'

describe AndroidNotifier do
  let(:created_at) { Time.now }

  let(:notification_attrs) { {
    "device_id" => "device id",
    "message" => {
      "data" => "data"
    }
  } }

  it "should send a GCM message" do
    container = double(:container, {
      :gcm_api_key => "gcm api key",
    })

    connection = double(:connection, :headers => {})
    faraday_klass = double(:Faraday)
    expect(faraday_klass).to receive(:new).and_return(connection).with({
      :url => "https://android.googleapis.com/"
    })

    expect(connection).to receive(:post).with("/gcm/send").and_yield(connection)
    expect(connection).to receive(:body=).with({
      :registration_ids => ["device id"],
      :data => {
        "data" => "data"
      }
    }.to_json)

    AndroidNotifier.notify(notification_attrs, faraday_klass, container)

    expect(connection.headers["Content-Type"]).to eq("application/json")
    expect(connection.headers["Authorization"]).to eq("key=gcm api key")
  end
end
