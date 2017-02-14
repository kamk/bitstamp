require 'active_support'
require 'active_model'
require 'bigdecimal'

require "bitstamp/version"
require "bitstamp/model/base"
require "bitstamp/model/ticker"
require "bitstamp/model/offer"
require "bitstamp/model/transaction"
require "bitstamp/model/balance"
require "bitstamp/model/order"
require "bitstamp/transactions"
require "bitstamp/orders"
require "bitstamp/error"
require "bitstamp/net_comm"
require "bitstamp/client"


module Bitstamp
  SERVICE_URI = "https://www.bitstamp.net/api"
  DEFAULT_CURR_PAIR = 'btcusd'

  private
  def self.to_api_params(opts)
    r = {}
    opts.each do |k, v|
      k = k.to_s.camelcase
      k[0] = k[0].downcase
      r[k.to_sym] = v
    end
    r
  end
  
end
