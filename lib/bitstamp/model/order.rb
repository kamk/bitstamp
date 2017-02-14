module Bitstamp::Model
  class Order < Base

    TYPES = { 0 => 'BUY', 1 => 'SELL' }

    attr_writer :net
    attr_accessor :id, :timestamp, :type, :price, :amount
  
    def initialize(attributes = {})
      attributes['timestamp'] = DateTime.parse(attributes.delete('datetime')).to_time
      super
      self.id = id.to_i
      self.type = TYPES[type.to_i]
      self.price = BigDecimal.new(price)
      self.amount = BigDecimal.new(amount)
    end
    
    
    def cancel!
      @net.post('cancel_order', id: id)
      true
    end

  end
end
