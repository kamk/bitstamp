# frozen_string_literal: true

module Bitstamp
  # This is main client interface
  class Client
    def initialize(client_id, key, secret, curr_pair = DEFAULT_CURR_PAIR)
      @net = Bitstamp::NetComm.new(client_id, key, secret, curr_pair)
      @curr_pair_sym = curr_pair
      @curr_pair = curr_pair[0..2], curr_pair[3..5]
    end

    # Get ticker data
    def ticker
      data = @net.get('ticker', append_pair: true)
      Bitstamp::Model::Ticker.new(data)
    end

    # Get an order book
    def order_book
      data = @net.get('order_book', append_pair: true)
      data['timestamp'] = Time.at(data['timestamp'].to_i)
      %w[asks bids].each do |dir|
        data[dir].map! { |e| Bitstamp::Model::Offer.new(e) }
      end
      data
    end

    # Access to tranasactions
    def transactions
      @transactions ||= Bitstamp::Transactions.new(@net, @curr_pair)
    end

    # Get balances
    def balances
      r = {}
      @curr_pair.each do |curr|
        data = @net.post('account_balances', append: [curr])
        r[curr.upcase] = Bitstamp::Model::Balance.new(
          balance: data['total'],
          available: data['available'],
          reserved: data['reserved']
        )
      end
      r
    end

    # Find out coin's withdrawal fee
    def coin_withdrawal_fee
      coin = @curr_pair[0]
      data = @net.post('fees/withdrawal', append: [coin])
      data['fee'].to_d
    end

    # Access to orders
    def orders
      @orders ||= Bitstamp::Orders.new(@net)
    end

    # Witdraw BTC coin
    def withdraw_btc(amount, address)
      r = @net.post('btc_withdrawal',
                    amount: amount,
                    address: address,
                    contact_thirdparty: false)
      r['id']
    end

    # Obtain deposit address
    def deposit_address
      r = @net.post('btc_address')
      r.include?('error') ? false : r['address']
    end

    # Transfer from MAIN to SUB account
    def transfer_main_to_sub(sub_account_id, amount, currency = 'BTC')
      r = @net.post('transfer-from-main', subAccount: sub_account_id,
                                          amount: amount,
                                          currency: currency)
      r['status'] == 'ok'
    end

    # Transfer from SUB to MAIN account
    def transfer_sub_to_main(amount, currency = 'BTC')
      r = @net.post('transfer-to-main', amount: amount,
                                        currency: currency)
      r['status'] == 'ok'
    end
  end
end
