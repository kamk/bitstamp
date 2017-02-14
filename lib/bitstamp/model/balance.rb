module Bitstamp::Model
  class Balance < Base
    
    attr_accessor :currency, :balance, :reserved, :available
    
    def initialize(attributes = {})
      super
      self.balance = BigDecimal(balance)
      self.reserved = BigDecimal(reserved)
      self.available = BigDecimal(available)
    end

  end  
end