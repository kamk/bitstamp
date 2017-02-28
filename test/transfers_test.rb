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


end