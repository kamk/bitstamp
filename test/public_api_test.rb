require 'test_helper'

class PublicApiTest < Minitest::Test

  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
  end


  def test_ticker
    VCR.use_cassette('ticker') do
      data = @bs.ticker
      assert_instance_of Bitstamp::Model::Ticker, data
      assert_equal to_bigd(64919.18), data.open
      assert_equal to_bigd(64902.25), data.last
      assert_equal to_bigd(68800.01), data.high
      assert_equal to_bigd(62856.71), data.low
      assert_equal to_bigd(3438.37163886), data.volume
      assert_equal to_bigd(64888.36), data.bid
      assert_equal to_bigd(64910.64), data.ask
      assert_equal Time.at(1636645588), data.timestamp
    end
  end


  def test_order_book
    VCR.use_cassette('order_book') do
      data = @bs.order_book
      # ASKS side
      assert_includes data, 'asks'
      [ { price: 64864.60,  amount: 0.03855143},
        { price: 64864.82, amount: 0.07710644 },
        { price: 64872.63, amount: 0.17250000 },
        { price: 64875.42, amount: 0.02312937 },
        { price: 64875.79, amount: 0.98229016 },
      ].each_with_index do |offer, i|
        check_order_book(offer, data['asks'][i])
      end
      # BIDS side
      assert_includes data, 'bids'
      [ { price: 64840.59, amount: 0.03855322 },
        { price: 64838.32, amount: 0.2 },
        { price: 64838.31, amount: 0.07710521 },
        { price: 64833.91, amount: 0.09614551 },
        { price: 64831.01, amount: 0.23095809 }
      ].each_with_index do |offer, i|
        check_order_book(offer, data['bids'][i])
      end
    end
  end


  def test_transactions
    VCR.use_cassette('public_transactions') do
      data = @bs.transactions.all
      [ { timestamp: 1636646521, transaction_id: "207338988", price: 64811.41, amount: 0.47 },
        { timestamp: 1636646521, transaction_id: "207338987", price: 64810.53, amount: 0.1 },
        { timestamp: 1636646517, transaction_id: "207338975", price: 64774.80, amount: -0.007 }
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