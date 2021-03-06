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
      self.price = BigDecimal(price)
      self.amount = BigDecimal(amount)
    end


    def current_status
      r = @net.post('order_status', id: id)
      r['status'].tr(' ', '_').downcase.to_sym
    end
    
    
    def cancel!
      @net.post('cancel_order', id: id)
      true
    end

  end
end
