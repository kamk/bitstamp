# frozen_string_literal: true

module Bitstamp
  module Model
    # User order
    class Order < Base
      TYPES = { 0 => 'BUY', 1 => 'SELL' }.freeze

      attr_writer :net
      attr_accessor :id, :timestamp, :type, :price, :amount, :amount_at_create, :currency_pair, :client_order_id

      def initialize(attributes = {})
        attributes['timestamp'] = DateTime.parse(attributes.delete('datetime')).to_time
        super
        self.id = id.to_i
        self.type = TYPES[type.to_i]
        self.price = BigDecimal(price)
        self.amount = BigDecimal(amount)
      end

      # Get order's current status
      def current_status
        r = @net.post('order_status', id: id)
        r['status'].tr(' ', '_').downcase.to_sym
      end

      # Cancel this order
      def cancel!
        @net.post('cancel_order', id: id)
        true
      end
    end
  end
end
