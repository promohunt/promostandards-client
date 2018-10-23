require_relative 'meta_api/client'
require 'promostandards/client/version'
require 'savon'

module PromoStandards
  class Client
    COMMON_SAVON_CLIENT_CONFIG = {
      # pretty_print_xml: true,
      # log: true,
      env_namespace: :soapenv,
      namespace_identifier: :ns
    }

    PRIMARY_IMAGE_PRECEDENCE = ['1006', ['1007', '1001', '2001'], ['1007', '1001'], '1007', '1003']

    def initialize(access_id:, password:, product_data_service_url:, media_content_service_url:)
      @access_id = access_id
      @password = password
      @product_data_service_url = product_data_service_url
      @media_content_service_url = media_content_service_url
    end

    def get_sellable_product_ids
      client = build_savon_client_for_product(@product_data_service_url)
      response = client.call('GetProductSellableRequest',
        message: {
          'shar:wsVersion' => '1.0.0',
          'shar:id' => @access_id,
          'shar:password' => @password,
          'shar:isSellable' => true
        },
        soap_action: 'getProductSellable'
      )
      response
        .body[:get_product_sellable_response][:product_sellable_array][:product_sellable]
        .map { |product_data| product_data[:product_id] }
        .uniq
    end

    def get_product_data(product_id)
      client = build_savon_client_for_product(@product_data_service_url)
      response = client.call('GetProductRequest',
        message: {
          'shar:wsVersion' => '1.0.0',
          'shar:id' => @access_id,
          'shar:password' => @password,
          'shar:localizationCountry' => 'US',
          'shar:localizationLanguage' => 'en',
          'shar:productId' => product_id
        },
        soap_action: 'getProduct'
      )
      product_hash = response.body[:get_product_response][:product]
      if(product_hash[:description]).is_a? Array
        product_hash[:description] = product_hash[:description].join('\n')
      end
      product_hash
    end

    def get_primary_image(product_id)
      client = build_savon_client_for_media(@media_content_service_url)
      response = client.call('GetMediaContentRequest',
        message: {
          'shar:wsVersion' => '1.1.0',
          'shar:id' => @access_id,
          'shar:password' => @password,
          'shar:mediaType' => 'Image',
          'shar:productId' => product_id,
        },
        soap_action: 'getMediaContent'
      )

      media_content = response.body.dig(:get_media_content_response, :media_content_array, :media_content)

      if media_content.is_a? Array
        primary_media_content = nil

        PRIMARY_IMAGE_PRECEDENCE.find do |image_precendence_number|
          primary_media_content = media_content.find do |media|
            class_type_array = media[:class_type_array]

            if class_type_array.is_a?(Hash)
              [media[:class_type_array][:class_type][:class_type_id]].include?(image_precendence_number)
            elsif class_type_array.is_a?(Array)
              [media[:class_type_array]].map { |item| item[:class_type][:class_type_id] }.include?(image_precendence_number)
            end
          end
        end
        primary_media_content || media_content.first
      else
        media_content
      end
    end

    private

    def build_savon_client_for_product(service_url)
      Savon.client COMMON_SAVON_CLIENT_CONFIG.merge(
        endpoint: service_url,
        namespace: 'http://www.promostandards.org/WSDL/ProductDataService/1.0.0/',
        namespaces: {
          'xmlns:shar' => 'http://www.promostandards.org/WSDL/ProductDataService/1.0.0/SharedObjects/'
        }
      )
    end

    def build_savon_client_for_media(service_url)
      Savon.client COMMON_SAVON_CLIENT_CONFIG.merge(
        endpoint: service_url,
        namespace: 'http://www.promostandards.org/WSDL/MediaService/1.0.0/',
        namespaces: {
          'xmlns:shar' => 'http://www.promostandards.org/WSDL/MediaService/1.0.0/SharedObjects/'
        }
      )
    end

  end
end
