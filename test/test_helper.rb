# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require "logger"
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
CLIENT_ID = 287410
KEY = 'SOPfNtFNYOihvPwmq3Eu7DxLdYcXh0RO'
SECRET = 'pXCG8aeWegLjREKA5kxlOpfsw0KsgNVz'
SUB_ID = 48489189
SUB_KEY = 'OJmo2hGSwhykUxpuU8946JOaWzOSAEIm'
SUB_SECRET = '8SsHzcgeMuwhXFCtgbKk215GNUISpHMy'

# BigDecimal numbers
def to_bigd(num)
  BigDecimal(num, 12)
end
