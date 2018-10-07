RSpec.describe Promostandards::Client do
  let(:ps_client) do
    ps_config = YAML::load_file(File.join(__dir__, 'ps_configs.yml')).first
    PromoStandards::Client.new ps_config
  end

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

    it 'returns the product ids' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_sellable_product_ids).to eql(
        ['prod id 1', 'prod id 2']
      )
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

    it 'extracts the media content object from the response' do
      allow(savon_client).to receive(:call).and_return savon_response

      expect(ps_client.get_primary_image('product_id')).to eql(url: 'image_url')
    end

    it 'returns the first one when the service reponse has an array of media content objects' do
      allow(savon_client).to receive(:call).and_return savon_response_with_muti_media_content

      expect(ps_client.get_primary_image('product_id')).to eql(url: 'image_url_1')
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

end
