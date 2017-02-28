module Bitstamp
  class Client
  
    def initialize(client_id, key, secret, curr_pair = DEFAULT_CURR_PAIR)
      @net = Bitstamp::NetComm.new(client_id, key, secret, curr_pair)
      @curr_pair = curr_pair[0..2], curr_pair[3..5]
    end


    # Get ticker data
    def ticker
      data = @net.get('ticker')
      Bitstamp::Model::Ticker.new(data)
    end


    def order_book
      data = @net.get('order_book')
      data['timestamp'] = Time.at(data['timestamp'].to_i)
      %w(asks bids).each do |dir|
        data[dir].map!{ |e| Bitstamp::Model::Offer.new(e) }
      end
      data
    end
    

    # Access to tranasactions
    def transactions
      @transactions ||= Bitstamp::Transactions.new(@net, @curr_pair)
    end


    # Get balances
    def balances
      r = Hash.new
      data = @net.post('balance')
      @curr_pair.each do |curr|
        r[curr.upcase] = Bitstamp::Model::Balance.new(
                            currency: curr.upcase,
                            balance: data["#{curr}_balance"],
                            available: data["#{curr}_available"],
                            reserved: data["#{curr}_reserved"]
                         )
      end
      r
    end
    

    # Access to orders
    def orders
      @orders ||= Bitstamp::Orders.new(@net)
    end

    def withdraw_btc(amount, address)
      r = @net.post('bitcoin_withdrawal', amount: amount, address: address)
      r['id']
    end


    def deposit_address
      @net.post('bitcoin_deposit_address') \
          .tr('"', '')
    end


    def unconfirmed_deposits
      @net.post('unconfirmed_btc')
    end


  end
end
