# frozen_string_literal: true

module Bitstamp
  # Public (all) or private (user) transactions
  class Transactions
    def initialize(net, curr_pair)
      @net = net
      @curr_pair = curr_pair
    end

    # Public transactions
    def all(recent = 'minute')
      @net.get('transactions', append_pair: true, time: recent) \
          .map { |t| Bitstamp::Model::Transaction.new(:public, @curr_pair, t) }
    end

    # User transactions
    def user(options = {})
      order_id = options.delete(:order_id)
      data = @net.post('user_transactions', options)
      data.select! { |t| t['order_id'] == order_id } if order_id
      data.map { |t| Bitstamp::Model::Transaction.new(:private, @curr_pair, t) } \
          .reject(&:nil?)
    end
  end
end
