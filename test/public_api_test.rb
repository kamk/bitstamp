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
      assert_equal to_bigd(23392.04), data.open
      assert_equal to_bigd(23664.08), data.last
      assert_equal to_bigd(23889.16), data.high
      assert_equal to_bigd(21915.52), data.low
      assert_equal to_bigd(4270.19817072), data.volume
      assert_equal to_bigd(23653.00), data.bid
      assert_equal to_bigd(23664.08), data.ask
      assert_equal Time.at(1658316448), data.timestamp
    end
  end

  def test_order_book
    VCR.use_cassette('order_book') do
      data = @bs.order_book
      # BIDS side
      assert_includes data, 'bids'
      [
        { price: 23804.70, amount: 1.30965829 },
        { price: 23804.11, amount: 0.14698650 },
        { price: 23801.07, amount: 0.54614901 }
      ].each_with_index do |offer, i|
        check_order_book(offer, data['bids'][i])
      end
      # ASKS side
      assert_includes data, 'asks'
      [
        { price: 23823.51, amount: 0.14698035 },
        { price: 23826.68, amount: 1.09443581 },
        { price: 23826.69, amount: 0.54451068 }
      ].each_with_index do |offer, i|
        check_order_book(offer, data['asks'][i])
      end
    end
  end

  def test_transactions
    VCR.use_cassette('public_transactions') do
      data = @bs.transactions.all
      [
        { timestamp: 1658332811, transaction_id: '241697316', price: 24181.24, amount: 0.14479 },
        { timestamp: 1658332787, transaction_id: '241697252', price: 24185.53, amount: 0.01135000 },
        { timestamp: 1658332784, transaction_id: '241697234', price: 24186.70, amount: 0.005 }
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
