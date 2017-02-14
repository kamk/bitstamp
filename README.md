# Bitstamp

This rubygem provides an interface for API requests to [Bitstamp](https://www.bitstamp.net) cryptocurrency exchange. The API itself is described at Bitstamp's website (link: https://www.bitstamp.net/api/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitstamp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitstamp

## Usage

Create a Bitstamp::Client instance as following:

```ruby
cmc = Bitstamp::Client.new(CLIENT_ID, PUBKEY, PRIVKEY)
```

All three parameters are optional and when not used only public requests can be made. Attempt to access private parts throws Bitstamp::Error exception.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kamk/bitstamp.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
