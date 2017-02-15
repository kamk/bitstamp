require 'test_helper'

class PrivateApiTest < Minitest::Test
    
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, PUBKEY, PRIVKEY)
  end
  

  def test_balances
    VCR.use_cassette('balance') do
      data = @bs.balances
      usd = data['USD']
      assert_equal 'USD', usd.currency
      assert_equal to_bigd(24.93), usd.balance
      assert_equal to_bigd(19.05), usd.reserved
      assert_equal to_bigd(5.88), usd.available
      btc = data['BTC']
      assert_equal 'BTC', btc.currency
      assert_equal to_bigd(0.025), btc.balance
      assert_equal to_bigd(0.02), btc.reserved
      assert_equal to_bigd(0.005), btc.available
    end
  end


  def test_orders
    VCR.use_cassette('orders') do
      data = @bs.orders.all
      sell_order = data[0]
      assert_equal 185891916, sell_order.id
      assert_equal Time.at(1487004605), sell_order.timestamp
      assert_equal 'SELL', sell_order.type
      assert_equal to_bigd(1025), sell_order.price
      assert_equal to_bigd(0.02), sell_order.amount
      buy_order = data[1]
      assert_equal 185891873, buy_order.id
      assert_equal Time.at(1487004584), buy_order.timestamp
      assert_equal 'BUY', buy_order.type
      assert_equal to_bigd(950), buy_order.price
      assert_equal to_bigd(0.02), buy_order.amount
    end
  end
  
  
  def test_find_order
    VCR.use_cassette('orders') do
      order = @bs.orders.find(185891873)
      assert_equal 'BUY', order.type
      assert_equal to_bigd(950), order.price
      assert_equal to_bigd(0.02), order.amount      
    end
  end



  def test_cancel_order
    VCR.use_cassette('cancel_order') do
      order = @bs.orders.find(185891916)
      assert order.cancel!
      order = @bs.orders.find(185891873)
      assert order.cancel!
    end
  end



  def test_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs.transactions.user(offset: 56, limit: 5)
      buy_tx = data[3]
      assert_equal Time.at(1440313297), buy_tx.timestamp
      assert_equal 9131434,             buy_tx.transaction_id
      assert_equal 'BUY',               buy_tx.transaction_type
      assert_equal to_bigd(231.16),     buy_tx.price
      assert_equal 'USD',               buy_tx.price_currency
      assert_equal to_bigd(0.03601406), buy_tx.amount
      assert_equal 'BTC',               buy_tx.amount_currency
      assert_equal to_bigd(0.03),       buy_tx.fee
      assert_equal 'USD',               buy_tx.fee_currency
      assert_equal 79467647,            buy_tx.order_id
      assert_equal to_bigd(8.33),       buy_tx.fiat_amount
      sell_tx = data[4]
      assert_equal Time.at(1439473725),  sell_tx.timestamp
      assert_equal 9080754,              sell_tx.transaction_id
      assert_equal 'SELL',               sell_tx.transaction_type
      assert_equal to_bigd(264.45),      sell_tx.price
      assert_equal 'USD',                sell_tx.price_currency
      assert_equal to_bigd(-0.03409194), sell_tx.amount
      assert_equal 'BTC',                sell_tx.amount_currency
      assert_equal to_bigd(0.03),        sell_tx.fee
      assert_equal 'USD',                sell_tx.fee_currency
      assert_equal 78374919,             sell_tx.order_id
      assert_equal to_bigd(-9.02),       sell_tx.fiat_amount
    end
  end


  def test_order_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs.transactions.user(offset: 56, limit: 5, order_id: 78374919)
      assert_equal 1,       data.length
      assert_equal 9080754, data[0].transaction_id
    end
  end


  def test_buy_limit
    VCR.use_cassette('buy_limit') do
      ord = @bs.orders.buy_limit(0.02, 950)
      assert_equal 185941655, ord.id
    end
  end


  def test_sell_limit
    VCR.use_cassette('sell_limit') do
      ord = @bs.orders.sell_limit(0.02, 1050)
      assert_equal 185941648, ord.id
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
