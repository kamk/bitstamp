# frozen_string_literal: true

require 'resolv'

module Bitstamp
  # Network communication with Bitstamp API
  class NetComm
    PRIVATE_RESOURCES = %w[
      account_balances user_transactions
      open_orders order_status cancel_order cancel_all_orders
      buy sell buy/market sell/market
      btc_address btc_withdrawal fees/withdrawal
      transfer-to-main transfer-from-main
    ].freeze

    SHA256_DIGEST = OpenSSL::Digest.new('sha256')

    class HttpGetRequest < Net::HTTP::Get
    end

    # POST request
    class HttpPostRequest < Net::HTTP::Post
      private

      def supply_default_content_type
        # skip setting default content-type to application/x-www-form-urlencoded
      end
    end

    def initialize(client_id, key, secret, curr_pair)
      @client_id = client_id
      @key = key
      @secret = secret
      @curr_pair = curr_pair
    end

    # Perform GET request
    def get(resource, params = {})
      perform(HttpGetRequest, resource, params)
    end

    # Perform POST request
    def post(resource, params = {})
      perform(HttpPostRequest, resource, params)
    end

    private

    def configured?
      @client_id && @key && @secret
    end

    # make a request
    def perform(req_klass, resource, params)
      result = {}
      uri_parts = [Bitstamp::SERVICE_URI, 'v2', resource]
      append = params.delete(:append)
      uri_parts += append if append
      uri_parts << @curr_pair if params.delete(:append_pair)
      uri_parts << '' # append '/' at the end
      uri = URI(uri_parts.join('/'))

      begin
        req = create_request(req_klass, uri, params)
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          request_set_private_resource_headers(req) if PRIVATE_RESOURCES.include?(resource)
          result = process_request(http, req)
        end
      rescue OpenSSL::OpenSSLError,
             Net::ProtocolError,
             Resolv::ResolvError,
             Timeout::Error,
             SocketError,
             SystemCallError => e
        raise Bitstamp::Error, "Network error: #{e}"
      end
      result
    end

    # create HTTP request
    def create_request(req_klass, uri, params)
      params = URI.encode_www_form(params)
      uri.query = params if params.present? && req_klass == HttpGetRequest

      req = req_klass.new(uri)
      if params.present? && req_klass == HttpPostRequest
        req['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = params
      end
      req
    end

    # process HTTP request
    def process_request(http, req)
      response = http.request(req)
      unless response.is_a?(Net::HTTPSuccess)
        http.finish
        raise Bitstamp::Error, format('%<code>d %<msg>s', code: response.code, msg: response.message)
      end
      output = JSON.parse(response.body)

      if output.instance_of?(Hash)
        err = output['error'] || (output['status'] == 'error' && output['reason'])
        if err
          http.finish
          raise Bitstamp::Error, err
        end
      end

      output
    end

    # prepare and set headers for private resource
    def request_set_private_resource_headers(req)
      raise Bitstamp::Error, 'Missing API keys' unless configured?

      req['X-Auth'] = "BITSTAMP #{@key}"
      req['X-Auth-Nonce'] = SecureRandom.uuid
      req['X-Auth-Timestamp'] = (Time.now.to_f * 1000).to_i
      req['X-Auth-Version'] = 'v2'
      req['X-Auth-Signature'] = OpenSSL::HMAC.hexdigest(SHA256_DIGEST, @secret, message_to_sign(req)).upcase
    end

    # construct the messagefor signing
    def message_to_sign(req)
      msg = req['X-Auth']
      msg << req.method
      %i[host path query].each do |component|
        value = req.uri.send(component)
        msg << value if value
      end
      %w[Content-Type X-Auth-Nonce X-Auth-Timestamp X-Auth-Version].each do |header|
        msg << req[header] if req[header]
      end
      msg << req.body.to_s
    end
  end
end
