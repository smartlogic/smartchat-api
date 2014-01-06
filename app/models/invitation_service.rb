module InvitationService
  def invite(inviter_email, invitee_email, message, container = AppContainer)
    container.queue.send_message({
      "queue" => "invitation",
      "invitee_email" => invitee_email,
      "inviter_email" => inviter_email,
      "message" => message
    }.to_json)
  end
  module_function :invite
end
