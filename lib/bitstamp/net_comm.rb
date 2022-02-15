module Bitstamp
  class NetComm

    PRIVATE_RESOURCES = %w(balance user_transactions open_orders order_status cancel_order cancel_all_orders buy sell withdrawal_requests btc_withdrawal btc_address transfer-to-main transfer-from-main)
    SKIP_CURR_RESOURCES = %w(user_transactions order_status cancel_order withdrawal_requests btc_withdrawal btc_address transfer-to-main transfer-from-main)

    SHA256_DIGEST = OpenSSL::Digest.new('sha256')

    class HttpGetRequest < Net::HTTP::Get
    end

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


    def get(resource, params = {})
      perform(HttpGetRequest, resource, params)
    end


    def post(resource, params = {})
      perform(HttpPostRequest, resource, params)
    end


    private
    def configured?
      @client_id && @key && @secret
    end
    
    
    def perform(req_klass, resource, params)
      result = {}
      uri_parts = [ Bitstamp::SERVICE_URI, 'v2', resource ]
      uri_parts << @curr_pair unless SKIP_CURR_RESOURCES.include?(resource) ||
                                     params.delete(:skip_currency_pair)
      uri_parts << ''   # append '/' at the end
      uri = URI(uri_parts.join('/'))
      
      params = URI.encode_www_form(params)
      uri.query = params if req_klass == HttpGetRequest && !params.empty?

      begin
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          req = req_klass.new(uri)
          if req_klass == HttpPostRequest && !params.empty?
            req['Content-Type'] = 'application/x-www-form-urlencoded'
            req.body = params
          end
          
          if PRIVATE_RESOURCES.include?(resource)
            raise Bitstamp::Error.new("Missing API keys") unless configured?
            req['X-Auth'] = 'BITSTAMP ' + @key
            req['X-Auth-Nonce'] = SecureRandom.uuid
            req['X-Auth-Timestamp'] = (Time.now.to_f * 1000).to_i
            req['X-Auth-Version'] = 'v2'
            req['X-Auth-Signature'] = OpenSSL::HMAC.hexdigest(
                                        SHA256_DIGEST, @secret, message_to_sign(req)
                                      ).upcase
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


    def message_to_sign(req)
      req['X-Auth'] +
        req.method +
        req.uri.host +
        req.uri.path +
        (req.uri.query ? ('?' + req.uri.query) : '') +
        req['Content-Type'].to_s +
        req['X-Auth-Nonce'] +
        req['X-Auth-Timestamp'] +
        req['X-Auth-Version'] +
        req.body.to_s
    end


  end
end