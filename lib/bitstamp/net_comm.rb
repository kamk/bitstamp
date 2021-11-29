require 'resolv'
require 'uri'
require 'net/http'
require 'json'
require 'openssl'

module Bitstamp
  class NetComm

    PRIVATE_RESOURCES = %w(balance user_transactions open_orders order_status cancel_order cancel_all_orders buy sell withdrawal_requests btc_withdrawal btc_address transfer-to-main transfer-from-main)
    SKIP_CURR_RESOURCES = %w(user_transactions order_status cancel_order withdrawal_requests btc_withdrawal btc_address transfer-to-main transfer-from-main)

    SHA256_DIGEST = OpenSSL::Digest.new('sha256')

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
      uri_parts = [ Bitstamp::SERVICE_URI, 'v2', resource ]
      uri_parts << @curr_pair unless SKIP_CURR_RESOURCES.include?(resource) ||
                                     params.delete(:skip_currency_pair)
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
      rescue OpenSSL::OpenSSLError, Net::ProtocolError, Resolv::ResolvError, Timeout::Error, SocketError, SystemCallError => err
        raise Bitstamp::Error.new("Network error: #{err}")
      end
      result
    end

    
    def signature_params
      nonce = (Time.now.to_f * 100).to_i
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