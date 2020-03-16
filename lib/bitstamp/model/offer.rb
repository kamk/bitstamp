module Bitstamp::Model
  class Offer < Base
    attr_accessor :price, :amount
    
    def initialize(data = [])
      self.price = BigDecimal(data[0])
      self.amount = BigDecimal(data[1])
    end

    
    def price_total
      price * amount
    end

  end
end