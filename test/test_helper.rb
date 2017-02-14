$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'vcr'
require 'pry'

require 'bitstamp'

require 'minitest/autorun'

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.default_cassette_options = {
    match_requests_on: [
      :method,
      VCR.request_matchers.uri_without_param(:nonce, :signature)
    ]
  }
  config.hook_into :webmock
end


# API keys
CLIENT_ID = 287410
PUBKEY = "1UiYqsdEoZrxqfDog4ReV5jwYkDtbR7q"
PRIVKEY = "89PqO49qeLVu8eMl9qES7qksfHLMqgb6"


# BigDecimal numbers
def to_bigd(num)
  BigDecimal.new(num, 12)
end
