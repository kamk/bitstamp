require 'test_helper'

class PrivateApiTest < Minitest::Test
    
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
  end
  

  def test_balances
    VCR.use_cassette('balance') do
      data = @bs.balances
      usd = data['USD']
      assert_equal 'USD', usd.currency
      assert_equal to_bigd(28.57), usd.balance
      assert_equal to_bigd(27.64), usd.reserved
      assert_equal to_bigd(0.93), usd.available
      btc = data['BTC']
      assert_equal 'BTC', btc.currency
      assert_equal to_bigd(0.00503), btc.balance
      assert_equal to_bigd(0.0005), btc.reserved
      assert_equal to_bigd(0.00453), btc.available
      assert_equal to_bigd(0.0005), data['FEE']
    end
  end



  def test_buy_limit
    VCR.use_cassette('buy_limit') do
      ord = @bs.orders.buy_limit(0.0005, 53000)
      assert_equal 1429943573118981, ord.id
    end
  end


  def test_sell_limit
    VCR.use_cassette('sell_limit') do
      ord = @bs.orders.sell_limit(0.0005, 55000)
      assert_equal 1429943656153088, ord.id
    end
  end

        
  def test_orders
    VCR.use_cassette('orders') do
      data = @bs.orders.all
      sell_order = data[0]
      assert_equal 1429943656153088, sell_order.id
      assert_equal Time.at(1637942312), sell_order.timestamp
      assert_equal 'SELL', sell_order.type
      assert_equal to_bigd(55000), sell_order.price
      assert_equal to_bigd(0.0005), sell_order.amount
      buy_order = data[1]
      assert_equal 1429943573118981, buy_order.id
      assert_equal Time.at(1637942292), buy_order.timestamp
      assert_equal 'BUY', buy_order.type
      assert_equal to_bigd(53000), buy_order.price
      assert_equal to_bigd(0.0005), buy_order.amount
    end
  end
  
  
  def test_find_order
    VCR.use_cassette('orders') do
      order = @bs.orders.find(1429943573118981)
      assert_equal 'BUY', order.type
      assert_equal to_bigd(53000), order.price
      assert_equal to_bigd(0.0005), order.amount      
    end
  end


  def test_order_status
    VCR.use_cassette('order_status') do
      order = @bs.orders.find(1429943656153088)
      assert_equal(:open, order.current_status)
    end
  end



  def test_cancel_order
    VCR.use_cassette('cancel_order') do
      order = @bs.orders.find(1429943573118981)
      assert order.cancel!
      order = @bs.orders.find(1429943656153088)
      assert order.cancel!
    end
  end


# [
#   {
#     "usd": "-27.50",
#     "btc_usd": 55000.0,
#     "order_id": 1429194368086017,
#     "datetime": "2021-11-26 08:37:52.735000",
#     "fee": "0.13750",
#     "btc": "0.00050000",
#     "type": "2",
#     "id": 210057823,
#     "eur": 0.0
#   },
#   {
#     "usd": "28.50",
#     "btc_usd": 57000.0,
#     "order_id": 1429194707623938,
#     "datetime": "2021-11-24 15:50:46.678000",
#     "fee": "0.14250",
#     "btc": "-0.00050000",
#     "type": "2",
#     "id": 209752784,
#     "eur": 0.0
#   }
# ]


  def test_transactions
    VCR.use_cassette('user_transactions') do
      data = @bs.transactions.user(offset: 0, limit: 2)
      buy_tx = data[0]
      assert_equal 1637915872.7350001,  buy_tx.timestamp.to_f
      assert_equal 210057823,           buy_tx.transaction_id
      assert_equal 'BUY',               buy_tx.transaction_type
      assert_equal to_bigd(55000),      buy_tx.price
      assert_equal 'USD',               buy_tx.price_currency
      assert_equal to_bigd(0.0005),     buy_tx.amount
      assert_equal 'BTC',               buy_tx.amount_currency
      assert_equal to_bigd(0.1375),     buy_tx.fee
      assert_equal 'USD',               buy_tx.fee_currency
      assert_equal 1429194368086017,    buy_tx.order_id
      assert_equal to_bigd(27.5),       buy_tx.fiat_amount
      sell_tx = data[1]
      assert_equal 1637769046.6780002,  sell_tx.timestamp.to_f
      assert_equal 209752784,           sell_tx.transaction_id
      assert_equal 'SELL',              sell_tx.transaction_type
      assert_equal to_bigd(57000),      sell_tx.price
      assert_equal 'USD',               sell_tx.price_currency
      assert_equal to_bigd(-0.0005),    sell_tx.amount
      assert_equal 'BTC',               sell_tx.amount_currency
      assert_equal to_bigd(0.14250),    sell_tx.fee
      assert_equal 'USD',               sell_tx.fee_currency
      assert_equal 1429194707623938,    sell_tx.order_id
      assert_equal to_bigd(-28.5),      sell_tx.fiat_amount
    end
  end


  def test_order_transactions
    VCR.use_cassette('user_transactions') do
      ;data = @bs.transactions.user(offset: 0, limit: 2, order_id: 1429194707623938)
      assert_equal 1,         data.length
      assert_equal 209752784, data[0].transaction_id
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
