require 'test_helper'

class TransfersTest < Minitest::Test
  
  def setup
    @bs = Bitstamp::Client.new(CLIENT_ID, KEY, SECRET)
  end


  def test_withdrawal
    VCR.use_cassette('withdrawal') do
      assert_equal 1404801, @bs.withdraw_btc(0.005, "14RbaeAUURBPsw6oQC52Ri4VMS2SR9ZqmK")
    end
  end


  def test_deposit_address
    VCR.use_cassette('deposit_address') do
      assert_equal '33evLwJfPoTi45KtiHtrcPiSgHu4dGTgxj', @bs.deposit_address
    end
  end
  

  def test_unconfirmed_deposits
    VCR.use_cassette('unconfirmed_deposits') do
      data = @bs.unconfirmed_deposits
      assert_equal(1, data.length)
      assert_equal({ "amount" => "0.0055",
                     "address" => "33evLwJfPoTi45KtiHtrcPiSgHu4dGTgxj",
                     "confirmations" => 0 },
                   data[0])
    end
  end


  def test_trasfer_main_to_sub
    VCR.use_cassette('main_to_sub') do
      assert @bs.transfer_main_to_sub(SUB_ID, 0.002)
    end
  end


  def test_trasfer_sub_to_main
    VCR.use_cassette('sub_to_main') do
      bs_sub = Bitstamp::Client.new(CLIENT_ID, SUB_KEY, SUB_SECRET)
      assert bs_sub.transfer_sub_to_main(0.002)
    end
  end


end