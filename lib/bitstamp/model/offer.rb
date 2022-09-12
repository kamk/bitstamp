# frozen_string_literal: true

module Bitstamp
  module Model
    # Order book entry
    class Offer < Base
      attr_accessor :price, :amount

      def initialize(data = [])
        super()
        self.price = Integer(data[0])
        self.amount = BigDecimal(data[1])
      end

      def price_total
        price * amount
      end
    end
  end
end
