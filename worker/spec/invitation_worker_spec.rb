require 'spec_helper'

describe InvitationWorker do
  it "should send an email" do
    invitation_attributes = {
      "invitee_email" => "eric@example.com",
      "inviter_email" => "sam@example.com",
      "message" => "hi"
    }

    container = Struct.new(:from_address).
      new("no-reply@example.com")

    InvitationWorker.new.perform(invitation_attributes, container)

    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq(["eric@example.com"])
    expect(mail.from).to eq(["no-reply@example.com"])
    expect(mail.subject).to eq("You're Invited to SmartChat")
    expect(mail.html_part.body).to match(/hi/)
    expect(mail.text_part.body).to match(/hi/)
  end
end
