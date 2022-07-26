# frozen_string_literal: true

module Bitstamp
  module Model
    # Public or private transaction
    class Transaction < Base
      PUBLIC_TYPES = { 0 => 'BUY', 1 => 'SELL' }.freeze
      PRIVATE_TYPES = { 0 => 'DEPOSIT', 1 => 'WITHDRAWAL', 2 => '_trade_', 14 => 'SUB_TRANSFER' }.freeze
      DEBIT_TRANSACTION_TYPES = %w[SELL WITHDRAWAL DEBIT].freeze

      attr_accessor :transaction_id, :timestamp, :transaction_type,
                    :amount, :amount_currency,
                    :price, :price_currency,
                    :fee, :fee_currency,
                    :description, :status, :order_id, :currency_pair

      def initialize(list_type, curr_pair, attributes = {})
        coin_code, fiat_code = curr_pair
        tx_type = attributes.delete('type').to_i
        case list_type
        when :public
          attributes['timestamp'] = attributes.delete('date')
          attributes['transaction_id'] = attributes.delete('tid')
          attributes['transaction_type'] = PUBLIC_TYPES[tx_type]
          super(attributes)
          self.timestamp = Time.at(timestamp.to_i)
          self.price = BigDecimal(price)
          self.price_currency = fiat_code.upcase
          self.amount = BigDecimal(amount)
          self.amount_currency = coin_code.upcase
          self.amount *= -1 if DEBIT_TRANSACTION_TYPES.include?(transaction_type)

        when :private
          attributes['timestamp'] = DateTime.parse(attributes.delete('datetime')).to_time
          attributes['transaction_id'] = attributes.delete('id')
          attributes['transaction_type'] = PRIVATE_TYPES[tx_type]
          attributes['amount'] = attributes.delete(coin_code)
          attributes['price'] = attributes.delete("#{coin_code}_#{fiat_code}")
          return unless attributes['price']

          %w[eur usd eur_usd].each { |c| attributes.delete(c) }
          super(attributes)
          self.amount = BigDecimal(amount.to_s)
          self.amount_currency = coin_code.upcase
          self.price = BigDecimal(price, 8)
          self.price_currency = fiat_code.upcase
          self.fee = BigDecimal(fee)
          self.fee_currency = fiat_code.upcase
          if transaction_type == '_trade_'
            self.transaction_type = amount.positive? ? 'BUY' : 'SELL'
          end
        end
      end

      def fiat_amount
        raise(Bitstamp::Error, "Cannot get fiat_amount for #{transaction_type}") unless price

        (price * amount).round(2)
      end

      def to_hash
        @raw
      end
    end
  end
end
