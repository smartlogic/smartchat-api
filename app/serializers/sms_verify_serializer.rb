class SmsVerifySerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :verification_code, :verification_phone_number

  def verification_code
    @object.sms_verification_code
  end

  def verification_phone_number
    AppContainer.verification_phone_number
  end

  def _links
    base_links = super

    base_links.merge({
      "self" => {
        "href" => sms_verify_users_url
      }
    })
  end
end
