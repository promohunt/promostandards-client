require_relative 'lib/promostandards/client'
require 'parallel'
require 'colorize'
require 'pry'

def print_data(service_host, product = {}, image = {}, fob_points = {}, prices = {}, errors=[])
  puts "\nFor #{service_host}".colorize(:green)
  begin
    p "Product ID - #{product[:product_id]}"
    p "Product name - #{product[:product_name]}"
    p "Product description - #{product[:description]}"
    p "Product primary image - #{image ? image[:url] : nil}"
    puts "Errors:\n- #{errors.join("\n- ")}".colorize(:red) unless errors.empty?
  rescue
    puts "❌ Something went wrong"
  end
end

# Requires a ps_configs.yml file. See ps_configs.yml.example
# Run: bundle exec ruby test_ps_services.rb
ps_configs = YAML::load_file(File.join(__dir__, 'ps_configs.yml'))

Parallel.each(ps_configs) do |ps_config|
  errors = []
  service_host = URI.parse(ps_config[:product_data_service_url]).host
  client = PromoStandards::Client.new ps_config
  begin
    product_ids = client.get_sellable_product_ids
  rescue
    errors << "Failed to get products ids from #{service_host}"
    next
  end
  sample_product_id = product_ids.sample
  begin
    product = client.get_product_data sample_product_id
  rescue
    errors << "Failed to get product data from #{service_host}"
  end
  begin
    image = client.get_primary_image sample_product_id
  rescue
    errors << "Failed to get image data from #{service_host}"
  end

  begin
    fob_points = client.get_fob_points sample_product_id
  rescue
    errors << "Failed to get fob points data from #{service_host}"
  end

  fob_id_for_price = if fob_points.is_a?(Hash)
    fob_points[:fob_id]
  elsif fob_points.is_a?(Array)
    fob_points[0][:fob_id]
  end

  begin
    prices = client.get_prices(sample_product_id, fob_id_for_price) if fob_id_for_price
  rescue
    errors << "Failed to get price data from #{service_host}"
  end
  print_data(service_host, product, image, fob_points, prices, errors)
end
