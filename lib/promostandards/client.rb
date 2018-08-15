require_relative 'soap/client'
require_relative 'meta_api/client'
require 'promostandards/client/version'

module PromoStandards
  class Client
    def get_sellable_product_ids_for(company_code:, username:, password:)
      soap_client = PromoStandards::SOAP::Client.new(
        svc_url: svc_url(company_code),
        username: username,
        password: password
      )
      soap_client.get_sellable_product_ids.map do |minimal_product|
        minimal_product[:product_id]
      end
    end

    private

    def svc_url(company_code)
      meta_api_client = PromoStandards::MetaApi::Client.new
      meta_api_client.get_product_svc_url(company_code)
    end
  end
end
