shared_context :routes do
  include Rails.application.routes.url_helpers

  let(:host) { "example.org" }
end
