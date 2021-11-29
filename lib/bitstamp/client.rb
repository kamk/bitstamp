module Bitstamp
  class Client
  
    def initialize(client_id, key, secret, curr_pair = DEFAULT_CURR_PAIR)
      @net = Bitstamp::NetComm.new(client_id, key, secret, curr_pair)
      @curr_pair_sym = curr_pair
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
        r['FEE'] = (data["fee"] / 1000).to_d
      end
      r
    end
    
    
    # Find out coin's withdrawal fee
    def coin_withdrawal_fee
      data = @net.post('balance', skip_currency_pair: true)
      data[@curr_pair[0] + '_withdrawal_fee'].to_d
    end
    

    # Access to orders
    def orders
      @orders ||= Bitstamp::Orders.new(@net)
    end

    def withdraw_btc(amount, address)
      r = @net.post('btc_withdrawal', amount: amount, address: address)
      r['id']
    end


    def deposit_address
      r = @net.post('btc_address')
      r.include?('error') ? false : r['address']
    end

    
    def transfer_main_to_sub(sub_account_id, amount, currency = 'BTC')
      r = @net.post('transfer-from-main', subAccount: sub_account_id,
                                          amount: amount,
                                          currency: currency)
      r['status'] == 'ok'
    end


    def transfer_sub_to_main(amount, currency = 'BTC')
      r = @net.post('transfer-to-main', amount: amount,
                                        currency: currency)
      r['status'] == 'ok'
    end
  end
end
