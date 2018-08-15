require 'httparty'

module PromoStandards
  module MetaApi
    class Client
      include HTTParty

      def get_product_svc_url(company_code)
        response = self.class.get(
          "https://services.promostandards.org/WebServiceRepository/WebServiceRepository.svc/json/companies/#{company_code}/endpoints/types/Product"
        )
        response.first['URL']
      end
    end
  end
end
