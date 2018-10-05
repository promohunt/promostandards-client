require_relative 'soap/client'
require_relative 'meta_api/client'
require 'promostandards/client/version'

module PromoStandards
  class Client
    def initialize(access_id:, password:, product_data_service_url:, media_content_service_url:)
      @soap_client = build_soap_client(access_id, password)
      @product_data_service_url = product_data_service_url
      @media_content_service_url = media_content_service_url
    end

    def get_sellable_product_ids
      @soap_client.get_sellable_product_ids(
        product_data_service_url: @product_data_service_url
      ).map do |minimal_product|
        minimal_product[:product_id]
      end
    end

    def get_product_data(product_id)
      @soap_client.get_product(
        product_data_service_url: @product_data_service_url,
        product_id: product_id
      )
    end

    def get_primary_image(product_id)
      @soap_client.get_primary_image(
        media_content_service_url: @media_content_service_url,
        product_id: product_id
      )
    end

    private

    def build_soap_client(access_id, password)
      PromoStandards::SOAP::Client.new(
        access_id: access_id,
        password: password
      )
    end
  end
end
