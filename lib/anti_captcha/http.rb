module AntiCaptcha
  #
  # AntiCaptcha::HTTP exposes common HTTP routines.
  #
  class HTTP

    #
    # Performs a POST HTTP request.
    # Anti Captcha API supports only POST requests.
    #
    # @param [Hash] options Options hash.
    # @param options [String] url      URL to be requested.
    # @param options [Hash]   payload  Data to be sent through the HTTP request.
    # @param options [Integer] timeout HTTP open/read timeout in seconds.
    #
    # @return [String] Response body of the HTTP request.
    #
    def self.post_request(options = {})
      uri     = URI(options[:url])
      payload = options[:json_payload] || '{}'
      timeout = options[:timeout] || 60
      headers = { 'User-Agent' => AntiCaptcha::USER_AGENT,
        'Content-Type' => 'application/json' }

      req = Net::HTTP::Post.new(uri.request_uri, headers)
      req.body = payload

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true if (uri.scheme == 'https')
      http.open_timeout = timeout
      http.read_timeout = timeout
      res = http.request(req)
      res.body

    rescue Net::OpenTimeout, Net::ReadTimeout
      raise AntiCaptcha::Error.new('Request timed out.')
    end
  end
end
