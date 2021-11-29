require 'test_helper'

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
      assert_equal 12941822, @bs.withdraw_btc(0.0005, "1CbccAu6DxoPcmP8GPvHjMsQGTrDTGrB6t")
    end
  end


  def test_deposit_address
    VCR.use_cassette('deposit_address') do
      assert_equal '3JocpswMF2CAcFc54JtKcYbF91TRS4ByjD', @bs.deposit_address
    end
  end
  

  def test_transfer_main_to_sub
    VCR.use_cassette('main_to_sub') do
      assert @bs.transfer_main_to_sub(SUB_ID, 0.00325)
    end
  end


  def test_transfer_sub_to_main
    VCR.use_cassette('sub_to_main') do
      bs_sub = Bitstamp::Client.new(CLIENT_ID, SUB_KEY, SUB_SECRET)
      assert bs_sub.transfer_sub_to_main(0.00125)
    end
  end


end