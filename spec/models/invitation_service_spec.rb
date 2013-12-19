require 'spec_helper'

describe InvitationService do
  class TestQueue
    attr_accessor :messages

    def initialize
      @messages = []
    end

    def send_message(message)
      @messages << message
    end
  end

  it "should send a message via SQS" do
    container = Struct.new(:sqs_queue).new(TestQueue.new)

    InvitationService.invite("sam@example.com", "eric@example.com", "hi", container)

    expect(container.sqs_queue.messages.first).to eq({
      "queue" => "invitation",
      "invitee_email" => "eric@example.com",
      "inviter_email" => "sam@example.com",
      "message" => "hi"
    }.to_json)
  end
end
