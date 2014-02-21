class FriendsSerializer < ActiveModel::ArraySerializer
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
      "self" => {
        "name" => "List of your friends",
        "href" => friends_url
      },
      "search" => {
        "name" => "Search for friends",
        "href" => search_friends_url() + "{?emails,phone_numbers}",
        "templated" => true
      }
    }

    if FriendService.has_groupies?(scope.id)
      hash[:_links]["smartchat:groupies"] = {
        "name" => "List out groupies",
        "href" => groupies_friends_url
      }
    end

    hash
  end

  private

  def scope
    @options[:scope]
  end
end
