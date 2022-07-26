# frozen_string_literal: true

require_relative 'test_helper'

class PrivateApiTest < Minitest::Test
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
  end

  def test_balances
    VCR.use_cassette('balance') do
      data = @bs.balances
      usd = data['USD']
      assert_equal 'USD', usd.currency
      assert_equal to_bigd(29.27), usd.balance
      assert_equal to_bigd(21.10), usd.reserved
      assert_equal to_bigd(8.17), usd.available
      btc = data['BTC']
      assert_equal 'BTC', btc.currency
      assert_equal to_bigd(0.00131778), btc.balance
      assert_equal to_bigd(0.001), btc.reserved
      assert_equal to_bigd(0.00031778), btc.available
      assert_equal to_bigd(0.0005), data['FEE']
    end
  end

  def test_buy_limit
    VCR.use_cassette('buy_limit') do
      ord = @bs.orders.buy_limit(0.0005, 23_000)
      assert_equal 1514129036304385, ord.id
    end
  end

  def test_sell_limit
    VCR.use_cassette('sell_limit') do
      ord = @bs.orders.sell_limit(0.0005, 24_000)
      assert_equal 1514129748602880, ord.id
    end
  end

  def test_orders
    VCR.use_cassette('orders') do
      data = @bs.orders.all
      sell_order = data[0]
      assert_equal 1514129748602880, sell_order.id
      assert_equal Time.at(1658495557, in: 'UTC'), sell_order.timestamp
      assert_equal 'SELL', sell_order.type
      assert_equal to_bigd(24_000), sell_order.price
      assert_equal to_bigd(0.0005), sell_order.amount
      buy_order = data[1]
      assert_equal 1514129036304385, buy_order.id
      assert_equal Time.at(1658495383, in: 'UTC'), buy_order.timestamp
      assert_equal 'BUY', buy_order.type
      assert_equal to_bigd(23_000), buy_order.price
      assert_equal to_bigd(0.0005), buy_order.amount
    end
  end

  def test_find_order
    VCR.use_cassette('orders') do
      order = @bs.orders.find(1514129036304385)
      assert_equal 'BUY', order.type
      assert_equal to_bigd(23_000), order.price
      assert_equal to_bigd(0.0005), order.amount
    end
  end

  def test_order_status
    VCR.use_cassette('order_status') do
      order = @bs.orders.find(1514129748602880)
      assert_equal(:open, order.current_status)
    end
  end

  def test_cancel_order
    VCR.use_cassette('cancel_order') do
      order = @bs.orders.find(1514129748602880)
      assert order.cancel!
      order = @bs.orders.find(1514129036304385)
      assert order.cancel!
    end
  end

  def test_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs.transactions.user(offset: 0, limit: 2)
      buy_tx = data[0]
      assert_equal 1658830310.921,      buy_tx.timestamp.to_f
      assert_equal 242306395,           buy_tx.transaction_id
      assert_equal 'SELL',              buy_tx.transaction_type
      assert_equal to_bigd(21113.64),   buy_tx.price
      assert_equal 'USD',               buy_tx.price_currency
      assert_equal to_bigd(-0.001),     buy_tx.amount
      assert_equal 'BTC',               buy_tx.amount_currency
      assert_equal to_bigd(0.0),        buy_tx.fee
      assert_equal 'USD',               buy_tx.fee_currency
      assert_equal 1515500897337344,    buy_tx.order_id
      assert_equal to_bigd(-21.11),     buy_tx.fiat_amount

      sell_tx = data[1]
      assert_equal 1658830255.468,      sell_tx.timestamp.to_f
      assert_equal 242306262,           sell_tx.transaction_id
      assert_equal 'BUY',               sell_tx.transaction_type
      assert_equal to_bigd(21127.98),   sell_tx.price
      assert_equal 'USD',               sell_tx.price_currency
      assert_equal to_bigd(0.001),      sell_tx.amount
      assert_equal 'BTC',               sell_tx.amount_currency
      assert_equal to_bigd(0.0),        sell_tx.fee
      assert_equal 'USD',               sell_tx.fee_currency
      assert_equal 1515500670201856,    sell_tx.order_id
      assert_equal to_bigd(21.13),      sell_tx.fiat_amount
    end
  end

  def test_order_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs.transactions.user(offset: 0, limit: 2, order_id: 1515500670201856)
      assert_equal 1,         data.length
      assert_equal 242306262, data[0].transaction_id
    end
  end

  # def test_buy_market
  #   VCR.use_cassette('buy_market') do
  #     ord = @bs.orders.buy_market(15)
  #     assert_equal XXX, ord.id
  #   end
  # end

  # def test_sell_market
  #   VCR.use_cassette('sell_market') do
  #     ord = @bs.orders.sell_market(0.02)
  #     assert_equal XXX, ord.id
  #   end
  # end
end
