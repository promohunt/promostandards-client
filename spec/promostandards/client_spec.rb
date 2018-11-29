RSpec.describe Promostandards::Client do
  let(:ps_config) do
    {
      access_id: 'access_id',
      password: 'password',
      product_data_service_url: 'https://psproductdata100.pcna.online/',
      media_content_service_url: 'https://psmediacontent110.pcna.online/',
      product_pricing_and_configuration_service_url: 'https://pspriceconfig100.pcna.online/'
    }
  end
  let(:ps_client) { PromoStandards::Client.new ps_config }
  let(:savon_client) { double('SavonClient') }

  before do
    allow(Savon).to receive(:client).and_return savon_client
  end

  describe '#get_sellable_product_ids' do
    let(:savon_response) do
      double(:savon_response, body: {
        get_product_sellable_response: {
          product_sellable_array: {
            product_sellable: [
              {
                product_id: 'prod id 1',
                part_id: 'part id 1'
              },
              {
                product_id: 'prod id 2',
                part_id: 'part id 2'
              }
            ]
          }
        }
      })
    end

    let(:savon_response_with_duplicates) do
      double(:savon_response, body: {
        get_product_sellable_response: {
          product_sellable_array: {
            product_sellable: [
              {
                product_id: 'prod id 1',
                part_id: 'part id 1'
              },
              {
                product_id: 'prod id 2',
                part_id: 'part id 2'
              },
              {
                product_id: 'prod id 2',
                part_id: 'part id 3'
              }
            ]
          }
        }
      })
    end

    it 'ensures the structure of the message body' do
      allow(savon_client).to receive(:call) do |arg1, arg2|
        expect(arg2[:message].keys).to eql(
          ["shar:wsVersion", "shar:id", "shar:password", "shar:isSellable"]
        )
        savon_response
      end

      ps_client.get_sellable_product_ids
    end

    it 'returns the product ids' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_sellable_product_ids).to eql(
        ['prod id 1', 'prod id 2']
      )
    end

    it 'removes duplicate product ids when returning' do
      allow(savon_client).to receive(:call).and_return savon_response_with_duplicates

      expect(ps_client.get_sellable_product_ids).to eql(
        ['prod id 1', 'prod id 2']
      )
    end
  end

  describe '#get_product_data' do
    let(:savon_response) do
      double(:savon_response, body: {
        get_product_response: {
          product: {
            product_id: 'product_id',
            product_name: 'product_name',
            description: 'product description'
          }
        }
      })
    end

    let(:savon_response_with_multi_description) do
      double(:savon_response, body: {
        get_product_response: {
          product: {
            description: [
              'product description 1',
              'product description 2'
            ]
          }
        }
      })
    end

    it 'ensures the structure of the message body' do
      allow(savon_client).to receive(:call) do |arg1, arg2|
        expect(arg2[:message].keys).to eql(
          ['shar:wsVersion', 'shar:id', 'shar:password', 'shar:localizationCountry', 'shar:localizationLanguage', 'shar:productId']
        )
        savon_response
      end

      ps_client.get_product_data 'product_id'
    end

    it 'extracts the product data from the response' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_product_data('product_id')).to eql(
        savon_response.body[:get_product_response][:product]
      )
    end

    it 'joins descriptions with \n if the response had a multiple description items' do
      allow(savon_client).to receive(:call).and_return savon_response_with_multi_description

      expect(ps_client.get_product_data('product_id')).to eql({
        description: 'product description 1\nproduct description 2'
      })
    end

  end

  describe '#get_primary_image' do
    let(:savon_response) do
      double(:savon_response, body: {
        get_media_content_response: {
          media_content_array: {
            media_content: { url: 'image_url' }
          }
        }
      })
    end

    let(:savon_response_with_muti_media_content) do
      double(:savon_response, body: {
        get_media_content_response: {
          media_content_array: {
            media_content: [
              { url: 'image_url_1' },
              { url: 'image_url_2' }
            ]
          }
        }
      })
    end

    let(:savon_response_with_error_1) do
      double(:savon_response, body: {
        error: {
          description: 'Some error'
        }
      })
    end

    let(:savon_response_with_error_2) do
      double(:savon_response, body: {
        get_media_content_response: {
          error_message: {
            code: "125",
            description: "Limit of request to a specific Media Classtype is not currently supported",
            :@xmlns=>"http://www.promostandards.org/WSDL/MediaService/1.0.0/SharedObjects/"
          },
          :@xmlns=>"http://www.promostandards.org/WSDL/MediaService/1.0.0/"
        }
      })
    end

    let(:savon_response_with_1006_image) do
      double(:savon_response, body: {
        get_media_content_response: {
          media_content_array: {
            media_content: [
              {
                product_id: "GNS6K424",
                url: "1006_image_url",
                media_type: "Image",
                class_type_array: { class_type: { class_type_id: "1006", class_type_name: "Rear" } },
                color: "Almond",
                single_part: true
              },
              {
                product_id: "GNS6K424",
                url: "1008_image_url",
                media_type: "Image",
                class_type_array: { class_type: { class_type_id: "1008", class_type_name: "Back" } },
                color: "Almond",
                single_part: true
              }
            ]
          }
        }
      })
    end

    let(:savon_response_with_multiple_class_types) do
      double(:savon_response, body: {
        get_media_content_response: {
          media_content_array: {
            media_content: [
              {
                product_id: "GNS6K424",
                url: "1009_image_url",
                media_type: "Image",
                class_type_array: { class_type: { class_type_id: "1009", class_type_name: "Rear" } },
                color: "Almond",
                single_part: true
              },
              {
                product_id: "GNS6K424",
                url: "1007_1001_2001_image_url",
                media_type: "Image",
                class_type_array: {
                  class_type: [
                    {
                      class_type_id: "1007",
                      class_type_name: "Back"
                    },
                    {
                      class_type_id: "1001",
                      class_type_name: "Front"
                    },
                    {
                      class_type_id: "2001",
                      class_type_name: "Top"
                      }
                  ]
                },
                color: "Almond",
                single_part: true
              }
            ]
          }
        }
      })
    end

    it 'raises an exception when the service URL is not available' do
      ps_config[:media_content_service_url] = nil
      ps_client = PromoStandards::Client.new ps_config

      expect do
        ps_client.get_primary_image 'product_id'
      end.to raise_error Promostandards::Client::NoServiceUrlError
    end

    it 'ensures the structure of the message body' do
      allow(savon_client).to receive(:call) do |arg1, arg2|
        expect(arg2[:message].keys).to eql(
          ['shar:wsVersion', 'shar:id', 'shar:password', 'shar:mediaType', 'shar:productId']
        )
        savon_response
      end

      ps_client.get_primary_image 'product_id'
    end

    it 'extracts the media content object from the response' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_primary_image('product_id')).to eql(url: 'image_url')
    end

    it 'returns the first one when the service reponse has an array of media content objects' do
      allow(savon_client).to receive(:call).and_return savon_response_with_muti_media_content

      expect(ps_client.get_primary_image('product_id')).to eql(url: 'image_url_1')
    end

    it 'returns nil if the response is not well formed' do
      [savon_response_with_error_1, savon_response_with_error_2].each do |savon_response_with_error|
        allow(savon_client).to receive(:call).and_return savon_response_with_error
        expect(ps_client.get_primary_image('product_id')).to be_nil
      end
    end

    it 'returns image with code 1006 if present' do
      allow(savon_client).to receive(:call).and_return savon_response_with_1006_image

      expect(ps_client.get_primary_image('product_id')).to eql({
        product_id: "GNS6K424",
        url: "1006_image_url",
        media_type: "Image",
        class_type_array: { class_type: { class_type_id: "1006", class_type_name: "Rear" } },
        color: "Almond",
        single_part: true
      })
    end

    it 'returns image with multiple codes if present in precedence order' do
      allow(savon_client).to receive(:call).and_return savon_response_with_multiple_class_types

      expect(ps_client.get_primary_image('product_id')).to eql({
        product_id: "GNS6K424",
        url: "1007_1001_2001_image_url",
        media_type: "Image",
        class_type_array: {
          class_type: [
            {
              class_type_id: "1007",
              class_type_name: "Back"
            },
            {
              class_type_id: "1001",
              class_type_name: "Front"
            },
            {
              class_type_id: "2001",
              class_type_name: "Top"
              }
          ]
        },
        color: "Almond",
        single_part: true
      })
    end
  end

  describe '#get_fob_points' do
    let(:savon_response) do
      double(:savon_response, body: {
        get_fob_points_response: {
          fob_point_array: {
            fob_point: [
              {
                product_id: 'product_id',
                product_name: 'product_name',
                description: 'product description'
              }
            ]
          }
        }
      })
    end

    it 'ensures the structure of the message body' do
      allow(savon_client).to receive(:call) do |arg1, arg2|
        expect(arg2[:message].keys).to eql(
          ['shar:wsVersion', 'shar:id', 'shar:password', 'shar:localizationCountry', 'shar:localizationLanguage', 'shar:productId']
        )
        savon_response
      end

      ps_client.get_fob_points 'product_id'
    end

    it 'extracts fob points from the response' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_fob_points('product_id')).to eql(
        savon_response.body[:get_fob_points_response][:fob_point_array][:fob_point]
      )
    end
  end

  describe '#get_prices' do
    let(:savon_response) do
      double(:savon_response, body: {
        get_configuration_and_pricing_response: {
          configuration: {
            part_array: {
              part: [
                {
                  part_group_required: true,
                  part_group: "1",
                  part_price_array: {
                    part_price: [
                      {
                        price: "100.00",
                        min_quantity: "100"
                      },
                      {
                        price: "200.00",
                        min_quantity: "25"
                      }
                    ]
                  }
                },
                {
                  part_group_required: true,
                  part_group: "2",
                  part_price_array: {
                    part_price: [
                      {
                        price: "50.00",
                        min_quantity: "100"
                      },
                      {
                        price: "100.00",
                        min_quantity: "25"
                      }
                    ]
                  }
                },
                {
                  part_group_required: false,
                  part_group: "1",
                  part_price_array: {
                    part_price: [
                      {
                        price: "50.00",
                        min_quantity: "100"
                      },
                      {
                        price: "250.00",
                        min_quantity: "25"
                      }
                    ]
                  }
                },
              ]
            }
          }
        }
      })
    end

    it 'ensures the structure of the message body' do
      allow(savon_client).to receive(:call) do |arg1, arg2|
        expect(arg2[:message].keys).to eql(
          ['shar:wsVersion', 'shar:id', 'shar:password', 'shar:localizationCountry', 'shar:localizationLanguage', 'shar:productId', 'shar:fobId', 'shar:currency', 'shar:priceType', 'shar:configurationType']
        )
        savon_response
      end

      ps_client.get_prices 'product_id', 'fob_id'
    end

    it 'extracts prices from the response' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_prices('product_id', 'fob_id')).to eql(
        savon_response.body[:get_configuration_and_pricing_response][:configuration][:part_array][:part]
      )
    end
  end
end
