# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'minitest/autorun'
require 'webmock/minitest'

require 'vcr'
require 'pry'

require 'bitstamp'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
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
KEY = '<MAIN KEY>'
SECRET = '<MAIN SECRET>'
SUB_ID = 0
SUB_KEY = '<SUB KEY>'
SUB_SECRET = '<SUB SECRET>'

# BigDecimal numbers
def to_bigd(num)
  BigDecimal(num, 12)
end
