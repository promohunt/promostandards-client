require 'savon'

module PromoStandards
  module SOAP
    class Client
      def initialize(svc_url:, access_id:, password:)
        @access_id = access_id
        @password = password
        @client = Savon.client(
          endpoint: svc_url,
          namespace: 'http://www.promostandards.org/WSDL/ProductDataService/1.0.0/',
          namespaces: {
            'xmlns:shar' => 'http://www.promostandards.org/WSDL/ProductDataService/1.0.0/SharedObjects/'
          }
        )
      end

      def get_sellable_product_ids
        response = @client.call('GetProductSellableRequest',
          message: {
            'shar:wsVersion' => '1.0.0', # This needs to be gotten from the meta api
            'shar:id' => @access_id,
            'shar:password' => @password,
            'shar:isSellable' => true
          },
          soap_action: 'getProductSellable'
        )
        response.body[:get_product_sellable_response][:product_sellable_array][:product_sellable]
      end
    end
  end
end
