require_relative 'meta_api/client'
require 'promostandards/client/version'
require 'promostandards/client/no_service_url_error'
require 'savon'
require 'promostandards/primary_image_extractor'

module PromoStandards
  class Client
    COMMON_SAVON_CLIENT_CONFIG = {
      # pretty_print_xml: true,
      # log: true,
      env_namespace: :soapenv,
      namespace_identifier: :ns
    }

    PRIMARY_IMAGE_PRECEDENCE = ['1006', ['1007', '1001', '2001'], ['1007', '1001'], '1007', ['1001', '2001'], '1001', '1003']

    def initialize(access_id:, password: nil, product_data_service_url:, media_content_service_url: nil, product_pricing_and_configuration_service_url: nil)
      @access_id = access_id
      @password = password
      @product_data_service_url = product_data_service_url
      @media_content_service_url = media_content_service_url
      @product_pricing_and_configuration_service_url = product_pricing_and_configuration_service_url
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
    rescue => exception
      raise exception.class, "#{exception} - get_product_data failed!"
    end

    def get_primary_image(product_id)
      raise Promostandards::Client::NoServiceUrlError, 'Media content service URL not set!' unless @media_content_service_url
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

      PrimaryImageExtractor.new.extract(media_content)
    rescue => exception
      raise exception.class, "#{exception} - get_primary_image failed!"
    end

    def get_fob_points(product_id)
      raise Promostandards::Client::NoServiceUrlError, 'Product pricing and configuration service URL not set!' unless @product_pricing_and_configuration_service_url
      client = build_savon_client_for_product_pricing_and_configuration(@product_pricing_and_configuration_service_url)
      response = client.call('GetFobPointsRequest',
        message: {
          'shar:wsVersion' => '1.0.0',
          'shar:id' => @access_id,
          'shar:password' => @password,
          'shar:localizationCountry' => 'US',
          'shar:localizationLanguage' => 'en',
          'shar:productId' => product_id
        },
        soap_action: 'getFobPoints'
      )

      fob_points_hash = response.body.dig(:get_fob_points_response, :fob_point_array, :fob_point)

      fob_points_hash
    rescue => exception
      raise exception.class, "#{exception} - get_fob_points failed!"
    end

    def get_prices(product_id, fob_id, configuration_type = 'Decorated')
      raise Promostandards::Client::NoServiceUrlError, 'Product pricing and configuration service URL not set!' unless @product_pricing_and_configuration_service_url
      client = build_savon_client_for_product_pricing_and_configuration(@product_pricing_and_configuration_service_url)
      response = client.call('GetConfigurationAndPricingRequest',
        message: {
          'shar:wsVersion' => '1.0.0',
          'shar:id' => @access_id,
          'shar:password' => @password,
          'shar:localizationCountry' => 'US',
          'shar:localizationLanguage' => 'en',
          'shar:productId' => product_id,
          'shar:fobId' => fob_id,
          'shar:currency' => 'USD',
          'shar:priceType' => 'List',
          'shar:configurationType' => configuration_type,
        },
        soap_action: 'getConfigurationAndPricing'
      )

      if configuration_type == 'Decorated' && response.body.dig(:get_configuration_and_pricing_response, :error_message, :code) == '406'
        get_prices(product_id, fob_id, 'Blank')
      end

      prices_hash = response.body.dig(:get_configuration_and_pricing_response, :configuration, :part_array, :part)
      prices_hash
    rescue => exception
      raise exception.class, "#{exception} - get_fob_points failed!"
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

    def build_savon_client_for_product_pricing_and_configuration(service_url)
      Savon.client COMMON_SAVON_CLIENT_CONFIG.merge(
        endpoint: service_url,
        namespace: 'http://www.promostandards.org/WSDL/PricingAndConfiguration/1.0.0/',
        namespaces: {
          'xmlns:shar' => 'http://www.promostandards.org/WSDL/PricingAndConfiguration/1.0.0/SharedObjects/'
        }
      )
    end
  end
end
