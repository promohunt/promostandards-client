# promostandards-client

A Ruby client to access [PromoStandards](https://promostandards.org) data from suppliers.

Currently, only interfaces the [Product Data](https://promostandards.org/service/view/7/) service. You can get ids of all sellable products for a given supplier.

#### TO DO
- [ ] Add tests
- [ ] Handle the case when the given company code is incorrect
- [ ] Return both `product_id` and `part_id` both
- [ ] Provide interfaces to other [services](https://promostandards.org/service/overview/) as well


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'promostandards-client',  :github => 'promohunt/promostandards-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install promostandards-client -s https://github.com/promohunt/promostandards-client

## Usage

```ruby
require 'promostandards/client.rb'

client = PromoStandards::Client.new

product_ids = client.get_sellable_product_ids_for(
  company_code: 'STAR',
  username: 'username',
  password: 'password'
)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/promohunt/promostandards-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `promostandards-client` project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/promohunt/promostandards-client/blob/master/CODE_OF_CONDUCT.md).
