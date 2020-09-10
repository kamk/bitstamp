$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'webmock/minitest'

require 'vcr'
require 'pry'

require 'bitstamp'


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
CLIENT_ID = 0
KEY = "<API key for main account>"
SECRET = "<API secret for main account>"
SUB_ID = 0
SUB_KEY = "<API key for sub account>"
SUB_SECRET = "<API secret for sub account>"



# BigDecimal numbers
def to_bigd(num)
  BigDecimal(num, 12)
end
