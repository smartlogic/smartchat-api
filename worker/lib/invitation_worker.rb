require 'mail'
require 'erb'

class InvitationWorker
  def perform(invitation_attributes, container = AppContainer)
    inviter_email = invitation_attributes["inviter_email"]
    message = invitation_attributes["message"]

    mail = Mail.new do
      from container.from_address
      to invitation_attributes["invitee_email"]
      subject "You're Invited to SmartChat"

      html_part do
        erb = File.read(File.expand_path("../../templates/invitation.html.erb", __FILE__))
        body ERB.new(erb).result(binding)
      end

      text_part do
        erb = File.read(File.expand_path("../../templates/invitation.txt.erb", __FILE__))
        body ERB.new(erb).result(binding)
      end
    end
    mail.deliver!
  end
end
