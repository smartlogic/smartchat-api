class MediaIndexSerializer < ActiveModel::ArraySerializer
  include Rails.application.routes.url_helpers

  delegate :default_url_options, :to => "ActionController::Base"

  def as_json(*args)
    hash = super

    hash[:_embedded] = { :media => hash.delete("media") }
    hash[:_links] = {
      "curies" =>  [{
        "name" =>  "smartchat",
        "href" =>  "https://smartchat.smartlogic.io/relations/{rel}",
        "templated" => true
      }],
    }

    hash
  end
end
