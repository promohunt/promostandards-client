# Requires a ps_configs.yml file. See ps_configs.yml.example
# bundle exec rspec spec/promostandards/integration_tests.rb
RSpec.describe 'Promostandards::Client integration tests' do
  ps_configs = YAML::load_file(File.join(__dir__, 'ps_configs.yml'))

  ps_configs.each do |ps_config|
    service_host = URI.parse(ps_config[:product_data_service_url]).host

    it "the service at #{service_host}" do
      client = PromoStandards::Client.new ps_config
      product_ids = client.get_sellable_product_ids
      start_time = Time.now
      sample_product_id = product_ids.sample
      product = client.get_product_data sample_product_id
      p "Product ID - #{product[:product_id]}"
      p "Product name - #{product[:product_name]}"
      p "Product description - #{product[:description]}"
      image = client.get_primary_image sample_product_id
      p "Product primary image - #{image[:url]}"
      p "Took #{Time.now - start_time} seconds"
      [
        product[:product_id],
        product[:product_name],
        product[:description],
        image[:url]
      ].each do |item|
        expect(item).not_to be_nil
      end
    end
  end
end
