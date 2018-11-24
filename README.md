# promostandards-client

A Ruby client to access [PromoStandards](https://promostandards.org) data from suppliers.

Currently, only interfaces some of the [Product Data](https://promostandards.org/service/view/7/) and the [Media Content](https://promostandards.org/service/view/11/) services.

#### TO DO

- [x] Add tests
- [x] Return `nil` when primary image is not available
- [ ] Provide interfaces to other [services](https://promostandards.org/service/overview/) as well

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'promostandards-client',  git: 'https://github.com/promohunt/promostandards-client'
```

And then execute:

    $ bundle

## Usage

```ruby
require 'promostandards/client.rb'

client = PromoStandards::Client.new(
  access_id: 'YOUR ID'
  password: 'YOUR PASSWORD'
  product_data_service_url: 'https://services.starline.com/CustomerProductDataService/CustomerProductDataService.svc'
  media_content_service_url: 'https://services.starline.com/MediaContentService/MediaContentService.svc'
  product_pricing_and_configuration_service_url: 'https://services.starline.com/ppc/PricingAndConfiguration.svc'
)

# Get sellable product ids
product_ids = client.get_sellable_product_ids

# Get product data
product_hash = client.get_product_data('product_id')

# Get primary product image
primary_image = client.get_primary_image('product_id')
```

## Testing PromoStandards end points

- Add credentials and service URLs to a `ps_configs.yml` (See `ps_configs.yml.example`)
- Run `bundle exec ruby test_ps_services.rb`

This would use the data in the YAML file, make sample requests to all the supplier services and log outcomes. This is useful to
test out the services end to end.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/promohunt/promostandards-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `promostandards-client` project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/promohunt/promostandards-client/blob/master/CODE_OF_CONDUCT.md).

## About PromoHunt

![PromoHunt Logo](https://s3.amazonaws.com/promohunt-production/static/brand/promohunt_logo_with_text_medium.png)

promostandards-client is maintained and funded by PromoHunt, inc. The names and logos for PromoHunt are trademarks of PromoHunt, inc.

PromoHunt is a browser extension that helps promotional products distributors & suppliers save time and money.
