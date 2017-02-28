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
KEY = "1UiYqsdEoZrxqfDog4ReV5jwYkDtbR7q"
SECRET = "89PqO49qeLVu8eMl9qES7qksfHLMqgb6"
SUB_ID = 48489189
SUB_KEY = "wf4qqkFlD5ARJBlp89eolHMD6JrU7bU0"
SUB_SECRET = "xdsH40rOhMONLe6aBEHbfbTXjN4tOaH1"



# BigDecimal numbers
def to_bigd(num)
  BigDecimal.new(num, 12)
end
