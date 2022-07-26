# frozen_string_literal: true

module Bitstamp
  # Collection of client orders
  class Orders
    def initialize(net)
      @net = net
    end

    def all
      @net.post('open_orders') \
          .map do |order|
            o = Bitstamp::Model::Order.new(order)
            o.net = @net
            o
          end
    end

    def find(order_id)
      order = @net.post('open_orders') \
                  .detect { |o| o['id'].to_i == order_id }
      return unless order

      order = Bitstamp::Model::Order.new(order)
      order.net = @net
      order
    end

    def buy_limit(amount, price)
      order = @net.post('buy', amount: amount, price: price)
      Bitstamp::Model::Order.new(order)
    end

    def sell_limit(amount, price)
      order = @net.post('sell', amount: amount, price: price)
      Bitstamp::Model::Order.new(order)
    end

    def buy_market(amount)
      order = @net.post('buy/market', amount: amount)
      Bitstamp::Model::Order.new(order)
    end

    def sell_market(amount)
      order = @net.post('sell/market', amount: amount)
      Bitstamp::Model::Order.new(order)
    end
  end
end
