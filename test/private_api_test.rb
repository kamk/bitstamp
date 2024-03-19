# frozen_string_literal: true

require_relative 'test_helper'

class PrivateApiTest < Minitest::Test
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
    @bs_sub = Bitstamp::Client.new(SUB_ID, SUB_KEY, SUB_SECRET)
  end

  def test_balances
    VCR.use_cassette('account_balances') do
      data = @bs.balances
      btc = data['BTC']
      assert_equal to_bigd(0.00178734), btc.balance
      assert_equal to_bigd(0.0005),     btc.reserved
      assert_equal to_bigd(0.00128734), btc.available
      usd = data['USD']
      assert_equal to_bigd(67.90), usd.balance
      assert_equal to_bigd(25.08), usd.reserved
      assert_equal to_bigd(42.82), usd.available
    end
  end

  def test_buy_limit
    VCR.use_cassette('buy_limit') do
      ord = @bs_sub.orders.buy_limit(0.0005, 50_000)
      assert_equal 1728261652815877, ord.id
    end
  end

  def test_sell_limit
    VCR.use_cassette('sell_limit') do
      ord = @bs_sub.orders.sell_limit(0.0005, 80_000)
      assert_equal 1728262007779328, ord.id
    end
  end

  def test_orders
    VCR.use_cassette('orders') do
      assert true
      data = @bs_sub.orders.all

      sell_order = data[0]
      assert_equal 1728262007779328, sell_order.id
      assert_equal Time.at(1710773941, in: 'UTC'), sell_order.timestamp
      assert_equal 'SELL', sell_order.type
      assert_equal to_bigd(80_000), sell_order.price
      assert_equal to_bigd(0.0005), sell_order.amount
      buy_order = data[1]
      assert_equal 1728261652815877, buy_order.id
      assert_equal Time.at(1710773854, in: 'UTC'), buy_order.timestamp
      assert_equal 'BUY', buy_order.type
      assert_equal to_bigd(50_000), buy_order.price
      assert_equal to_bigd(0.0005), buy_order.amount
    end
  end

  def test_find_order
    VCR.use_cassette('orders') do
      order = @bs_sub.orders.find(1728261652815877)
      assert_equal 'BUY', order.type
      assert_equal to_bigd(50_000), order.price
      assert_equal to_bigd(0.0005), order.amount
    end
  end

  def test_order_status
    VCR.use_cassette('order_status') do
      order = @bs_sub.orders.find(1728262007779328)
      assert_equal(:open, order.current_status)
    end
  end

  def test_cancel_order
    VCR.use_cassette('cancel_order') do
      order = @bs_sub.orders.find(1728262007779328)
      assert order.cancel!
      order = @bs_sub.orders.find(1728261652815877)
      assert order.cancel!
    end
  end

  def test_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs_sub.transactions.user(offset: 0, limit: 2)

      buy_tx = data[0]
      assert_equal 1710776707.4750001,  buy_tx.timestamp.to_f
      assert_equal 328165032,           buy_tx.transaction_id
      assert_equal 'SELL',              buy_tx.transaction_type
      assert_equal to_bigd(67318),      buy_tx.price
      assert_equal 'USD',               buy_tx.price_currency
      assert_equal to_bigd(-0.0005),    buy_tx.amount
      assert_equal 'BTC',               buy_tx.amount_currency
      assert_equal to_bigd(0.13464),    buy_tx.fee
      assert_equal 'USD',               buy_tx.fee_currency
      assert_equal 1728273337618434,    buy_tx.order_id
      assert_equal to_bigd(-33.66),     buy_tx.fiat_amount

      sell_tx = data[1]
      assert_equal 1710776647.964,      sell_tx.timestamp.to_f
      assert_equal 328164894,           sell_tx.transaction_id
      assert_equal 'BUY',               sell_tx.transaction_type
      assert_equal to_bigd(67322),      sell_tx.price
      assert_equal 'USD',               sell_tx.price_currency
      assert_equal to_bigd(0.0005),     sell_tx.amount
      assert_equal 'BTC',               sell_tx.amount_currency
      assert_equal to_bigd(0.13464),    sell_tx.fee
      assert_equal 'USD',               sell_tx.fee_currency
      assert_equal 1728273093865474,    sell_tx.order_id
      assert_equal to_bigd(33.66),      sell_tx.fiat_amount
    end
  end

  def test_order_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs.transactions.user(offset: 0, limit: 2, order_id: 1728273337618434)
      assert_equal 1,         data.length
      assert_equal 328165032, data[0].transaction_id
    end
  end

  # def test_buy_market
  #   VCR.use_cassette('buy_market') do
  #     ord = @bs_sub.orders.buy_market(15)
  #     assert_equal XXX, ord.id
  #   end
  # end

  # def test_sell_market
  #   VCR.use_cassette('sell_market') do
  #     ord = @bs_sub.orders.sell_market(0.02)
  #     assert_equal XXX, ord.id
  #   end
  # end
end
