# frozen_string_literal: true

module Bitstamp
  module Model
    # Ticker informations
    class Ticker < Base
      include ActiveModel::Model

      attr_accessor :open, :last, :high, :low, :vwap, :volume, :bid, :ask, :timestamp

      def initialize(attributes = {})
        super
        attributes.each do |a, v|
          next if a == 'timestamp'

          public_send("#{a}=".to_sym, BigDecimal(v))
        end
        self.timestamp = Time.at(attributes['timestamp'].to_i)
      end
    end
  end
end
