module ApplicationSerializer
  def self.included(base)
    base.class_eval do
      root false

      attributes :_links
    end
  end

  def _links
    {
      "curies" =>  [{
        "name" =>  "smartchat",
        "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
        "templated" => true
      }]
    }
  end
end
