require_relative 'lib/promostandards/client'
require 'parallel'
require 'colorize'
require 'pry'

def print_data(service_host, product = {}, image = {})
  puts "For #{service_host}".colorize(:green)
  p "Product ID - #{product[:product_id]}"
  p "Product name - #{product[:product_name]}"
  p "Product description - #{product[:description]}"
  p "Product primary image - #{image[:url]}"
end

# Requires a ps_configs.yml file. See ps_configs.yml.example
# Run: bundle exec ruby test_ps_services.rb
ps_configs = YAML::load_file(File.join(__dir__, 'ps_configs.yml'))

Parallel.each(ps_configs) do |ps_config|
  service_host = URI.parse(ps_config[:product_data_service_url]).host
  client = PromoStandards::Client.new ps_config
  begin
    product_ids = client.get_sellable_product_ids
  rescue
    puts "Failed to get products ids from #{service_host}".colorize(:red)
    next
  end
  sample_product_id = product_ids.sample
  begin
    product = client.get_product_data sample_product_id
  rescue
    puts "Failed to get product data from #{service_host}".colorize(:red)
  end
  begin
    image = client.get_primary_image sample_product_id
  rescue
    puts "Failed to get image data from #{service_host}".colorize(:red)
  end
  print_data(service_host, product, image)
end
