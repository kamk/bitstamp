module Bitstamp::Model
  class Base
    include ActiveModel::Model
    
    # def initialize(attributes = {})
    #   @raw = attributes
    #   super Hash[attributes.map{ |a, v| [a.underscore, v] }]
    # end
    #
    #
    # def to_hash
    #   @raw
    # end

  end
  
end