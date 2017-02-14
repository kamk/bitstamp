require 'test_helper'

class PublicApiTest < Minitest::Test

  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, PUBKEY, PRIVKEY)
  end


  def test_ticker
    VCR.use_cassette('ticker') do
      data = @bs.ticker
      assert_instance_of Bitstamp::Model::Ticker, data
      assert_equal to_bigd(1000.73), data.open
      assert_equal to_bigd(992.16), data.last
      assert_equal to_bigd(1010.99), data.high
      assert_equal to_bigd(975.10), data.low
      assert_equal to_bigd(3551.86141636), data.volume
      assert_equal to_bigd(990.11), data.bid
      assert_equal to_bigd(992.16), data.ask
      assert_equal Time.at(1486979366), data.timestamp
    end
  end


  def test_order_book
    VCR.use_cassette('order_book') do
      data = @bs.order_book
      # ASKS side
      assert_includes data, 'asks'
      [ { price: 995.06,  amount: 6.26490823 },
        { price: 995.08, amount: 4.68 },
        { price: 995.11, amount: 0.173 },
        { price: 995.12, amount: 7.10593961 },
        { price: 996.05, amount: 10 },
      ].each_with_index do |offer, i|
        check_order_book(offer, data['asks'][i])
      end
      # BIDS side
      assert_includes data, 'bids'
      [ { price: 994.95, amount: 0.01 },
        { price: 994.51, amount: 23.73509177 },
        { price: 994.5,  amount: 0.54519969 },
        { price: 994.41, amount: 0.01 },
        { price: 994.03, amount: 0.63086600 }
      ].each_with_index do |offer, i|
        check_order_book(offer, data['bids'][i])
      end
    end
  end


  def test_transactions
    VCR.use_cassette('public_transactions') do
      data = @bs.transactions.all
      [ { timestamp: 1486989854, transaction_id: "13322326", price: 994.56, amount: -0.026 },
        { timestamp: 1486989799, transaction_id: "13322325", price: 997.98, amount: 0.00896281 },
        { timestamp: 1486989799, transaction_id: "13322324", price: 997.56, amount: 0.01211958 }
      ].each_with_index do |tx, i|
        assert_equal Time.at(tx[:timestamp]), data[i].timestamp
        assert_equal tx[:transaction_id], data[i].transaction_id
        assert_equal to_bigd(tx[:price]), to_bigd(data[i].price)
        assert_equal 'USD', data[i].price_currency
        assert_equal to_bigd(tx[:amount]), to_bigd(data[i].amount)
        assert_equal 'BTC', data[i].amount_currency
      end
    end
  end


  private
  def check_order_book(offer, data)
    price, amount = to_bigd(offer[:price]), to_bigd(offer[:amount])
    assert_equal price, data.price
    assert_equal amount, data.amount
    assert_equal price * amount, data.price_total
  end


end