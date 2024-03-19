# frozen_string_literal: true

require_relative 'test_helper'

class PublicApiTest < Minitest::Test
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
  end

  def test_ticker
    VCR.use_cassette('ticker') do
      data = @bs.ticker
      assert_instance_of Bitstamp::Model::Ticker, data
      assert_equal to_bigd(67603), data.open
      assert_equal to_bigd(63336), data.last
      assert_equal to_bigd(68123), data.high
      assert_equal to_bigd(62443), data.low
      assert_equal to_bigd(4304.28916156), data.volume
      assert_equal to_bigd(63337), data.bid
      assert_equal to_bigd(63345), data.ask
      assert_equal Time.at(1710856561), data.timestamp
    end
  end

  def test_order_book
    VCR.use_cassette('order_book') do
      data = @bs.order_book
      # BIDS side
      assert_includes data, 'bids'
      [
        { price: 63024, amount: 0.09916856 },
        { price: 63021, amount: 0.02356749 },
        { price: 63020, amount: 0.01586779 }
      ].each_with_index do |offer, i|
        check_order_book(offer, data['bids'][i])
      end
      # ASKS side
      assert_includes data, 'asks'
      [
        { price: 63042, amount: 0.79800415 },
        { price: 63043, amount: 0.079 },
        { price: 63044, amount: 0.07933944 }
      ].each_with_index do |offer, i|
        check_order_book(offer, data['asks'][i])
      end
    end
  end

  def test_transactions
    VCR.use_cassette('public_transactions') do
      data = @bs.transactions.all
      [
        { timestamp: 1710859896, transaction_id: '328534803', price: 62879, amount: 0.0004796 },
        { timestamp: 1710859891, transaction_id: '328534787', price: 62900, amount: 0.00614 },
        { timestamp: 1710859889, transaction_id: '328534779', price: 62921, amount: 0.00030909 }
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
    price = to_bigd(offer[:price])
    amount = to_bigd(offer[:amount])
    assert_equal price, data.price
    assert_equal amount, data.amount
    assert_equal price * amount, data.price_total
  end
end
