require 'uri'
require 'net/http'
require 'json'
require 'openssl'

module Bitstamp
  class NetComm

    PRIVATE_RESOURCES = %w(balance user_transactions open_orders order_status cancel_order cancel_all_orders buy sell withdrawal_requests bitcoin_withdrawal bitcoin_deposit_address unconfirmed_btc transfer-to-main transfer-from-main)
    V1_RESOURCES = %w(order_status cancel_all_orders withdrawal_requests bitcoin_withdrawal bitcoin_deposit_address unconfirmed_btc)
    SKIP_CURR_RESOURCES = %w(user_transactions cancel_order transfer-to-main transfer-from-main)
    PLAIN_RESPONSES = %w(bitcoin_deposit_address)

    SHA256_DIGEST = OpenSSL::Digest.new('sha256')
    CHANNEL_NONCE_OFFSET = [2, 5, 11, 17, 23, 31, 41, 47, 59, 67, 73, 83]

    cattr_writer :channel
    
    def initialize(client_id, key, secret, curr_pair)
      @client_id = client_id
      @key = key
      @secret = secret
      @curr_pair = curr_pair
    end


    def get(resource, params = {})
      perform(Net::HTTP::Get, resource, params)
    end


    def post(resource, params = {})
      perform(Net::HTTP::Post, resource, params)
    end


    private
    def configured?
      @client_id && @key && @secret
    end
    
        
    def perform(req_klass, resource, params)
      result = {}
      if PRIVATE_RESOURCES.include?(resource)
        raise Bitstamp::Error.new("Missing API keys") unless configured?
        params.merge!(signature_params)
      end
      uri_parts = [ Bitstamp::SERVICE_URI ]
      if V1_RESOURCES.include?(resource)
        uri_parts << resource
      else
        uri_parts << 'v2'
        uri_parts << resource
        uri_parts << @curr_pair unless SKIP_CURR_RESOURCES.include?(resource)
      end
      uri_parts << ''   # append '/' at the end
      uri = URI(uri_parts.join('/'))
      
      params = URI.encode_www_form(params)
      uri.query = params if req_klass == Net::HTTP::Get && !params.empty?

      begin
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          req = req_klass.new(uri)
          if req_klass == Net::HTTP::Post
            req['Content-Type'] = 'application/x-www-form-urlencoded'
            req.body = params
          end
          response = http.request(req)
          unless response.is_a?(Net::HTTPSuccess)
            http.finish
            raise Bitstamp::Error.new(sprintf("%d %s", response.code, response.message))
          end
          return response.body if PLAIN_RESPONSES.include?(resource)
          result = JSON.parse(response.body)
          if result.class == Hash            
            err = result['error'] ||
                (result['status'] && result['status'] == 'error' && result['reason'])
            if err
              http.finish
              raise Bitstamp::Error.new(err)
            end
          end
        end
      rescue SocketError, SystemCallError => err
        if err.is_a?(SystemCallError)
          raise if err.class.name !~ /^Errno::/
        end
        raise Bitstamp::Error.new("Network error: #{err}")
      end
      result
    end

    
    def signature_params
      nonce = (Time.now.to_f * 100).to_i
      chan = @@channel.to_i
      if chan > 0
        offset = CHANNEL_NONCE_OFFSET[chan - 1]
        mod = nonce % offset
        nonce += (offset - mod) if mod > 0
        sleep offset / 100.0
      end
      message = sprintf("%d%d%s", nonce, @client_id, @key)
      sleep 1
      {
        key: @key,
        nonce: nonce,
        signature: OpenSSL::HMAC.hexdigest(SHA256_DIGEST, @secret, message) \
                                .upcase
      }
    end


  end
end