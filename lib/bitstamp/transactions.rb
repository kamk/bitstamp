module Bitstamp
  class Transactions
    
    def initialize(net, curr_pair)
      @net = net
      @curr_pair = curr_pair
    end

    # Public transactions
    def all(recent = 'hour')
      @net.get('transactions', time: recent) \
          .map{ |t| Bitstamp::Model::Transaction.new(:public, @curr_pair, t) }
    end

    
    # User transactions
    def user(options = {})
      @net.post('user_transactions', options) \
          .map{ |t| Bitstamp::Model::Transaction.new(:private, @curr_pair, t) }
    end


  end
end