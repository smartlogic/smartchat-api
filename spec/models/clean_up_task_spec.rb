require 'spec_helper'

describe CleanUpTask do
  it "should send SQS clean up messages for all users in the system" do
    user_1 = create_user(:username => "eric", :email => "eric@example.com")
    user_2 = create_user(:username => "sam", :email => "sam@example.com")

    timestamp = 2.weeks.ago
    queue = double(:queue)

    expect(queue).to receive(:send_message).with({
      "queue" => "clean-up",
      "user_id" => user_1.id,
      "timestamp" => timestamp
    }.to_json)
    expect(queue).to receive(:send_message).with({
      "queue" => "clean-up",
      "user_id" => user_2.id,
      "timestamp" => timestamp
    }.to_json)

    container = double(:container, :queue => queue, :clean_up_limit => -> { timestamp })

    CleanUpTask.perform(container)
  end
end
