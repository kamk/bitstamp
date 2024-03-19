# frozen_string_literal: true

require_relative 'test_helper'

class TransfersTest < Minitest::Test
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
  end

  def test_withdrawal_fee
    VCR.use_cassette('withdrawal_fee') do
      assert_equal(to_bigd(0.0005), @bs.coin_withdrawal_fee)
    end
  end

  def test_withdrawal
    VCR.use_cassette('withdrawal') do
      assert_equal 20254671, @bs.withdraw_btc(0.0005, '1CbccAu6DxoPcmP8GPvHjMsQGTrDTGrB6t')
      assert true
    end
  end

  def test_deposit_address
    VCR.use_cassette('deposit_address') do
      assert_equal 'bc1qaezu06lg6dke3vtqjvr7t2jpw56r72rt7ycwaarskfd3eg6gywfsletxl3', @bs.deposit_address
    end
  end

  def test_transfer_main_to_sub
    VCR.use_cassette('main_to_sub') do
      assert @bs.transfer_main_to_sub(SUB_ID, 0.0005)
    end
  end

  def test_transfer_sub_to_main
    VCR.use_cassette('sub_to_main') do
      bs_sub = Bitstamp::Client.new(CLIENT_ID, SUB_KEY, SUB_SECRET)
      assert bs_sub.transfer_sub_to_main(0.0005)
    end
  end
end
