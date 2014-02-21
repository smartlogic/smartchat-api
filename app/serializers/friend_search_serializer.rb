class FriendSearchSerializer < ActiveModel::ArraySerializer
  include Rails.application.routes.url_helpers

  delegate :default_url_options, :to => "ActionController::Base"

  def as_json(*args)
    hash = super

    hash[:_embedded] = { :friends => hash.delete("friends") }
    hash[:_links] = {
      "curies" =>  [{
        "name" =>  "smartchat",
        "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
        "templated" => true
      }],
      "search" => {
        "name" => "Search for friends",
        "href" => search_friends_url() + "{?emails,phone_numbers}",
        "templated" => true
      }
    }

    hash
  end
end
