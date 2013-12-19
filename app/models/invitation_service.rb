module InvitationService
  def invite(email, message, container = AppContainer)
    container.sqs_queue.send_message({
      "queue" => "invitation",
      "email" => email,
      "message" => message
    }.to_json)
  end
  module_function :invite
end
