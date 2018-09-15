module AntiCaptcha
  # AntiCaptcha::Client is a client that communicates with the Anti Captcha API:
  # https://anti-captcha.com.
  #
  class Client
    BASE_URL = 'https://api.anti-captcha.com/:action'

    attr_accessor :client_key, :timeout, :polling

    #
    # Creates a client for the Anti Captcha API.
    #
    # @param [String] client_key The key of the Anti Captcha account.
    # @param [Hash]   options  Options hash.
    # @option options [Integer] :timeout (60) Seconds before giving up of a
    #                                         captcha being solved.
    # @option options [Integer] :polling  (5) Seconds before checking answer
    #                                         again.
    #
    # @return [AntiCaptcha::Client] A Client instance.
    #
    def initialize(client_key, options = {})
      self.client_key = client_key
      self.timeout    = options[:timeout] || 60
      self.polling    = options[:polling] || 5
    end

    #
    # Decodes an image CAPTCHA.
    #
    # @see `AntiCaptcha::Client#decode_image!`
    #
    def decode_image(options)
      decode_image!(options)
    rescue
      AntiCaptcha::ImageToTextSolution.new
    end

    #
    # Decodes an image CAPTCHA.
    #
    # @param [Hash] options Options hash.
    #   @option options [String]  :body64 File body encoded in base64. Make sure to
    #                                     send it without line breaks.
    #   @option options [String]  :body   Binary file body.
    #   @option options [String]  :path   File path of the image to be decoded.
    #   @option options [File]    :file   File instance with image to be
    #                                     decoded.
    #   @option options [Boolean] :phrase If the worker must enter an answer
    #                                     with at least one "space".
    #   @option options [Boolean] :case If the answer must be entered with case
    #                                   sensitivity.
    #   @option options [Integer] :numeric 0 - no requirements; 1 - only numbers
    #                                      are allowed; 2 - any letters are
    #                                      allowed except numbers.
    #   @option options [Boolean] :math If the answer must be calculated.
    #   @option options [Integer] :min_length Defines minimum length of the
    #                                         answer. 0 - no requirements.
    #   @option options [Integer] :max_length Defines maximum length of the
    #                                         answer. 0 - no requirements.
    #
    # @return [AntiCaptcha::ImageToTextSolution] The solution of the image
    #                                            CAPTCHA.
    #
    def decode_image!(options)
      started_at = Time.now

      options[:body64] = load_captcha(options)
      task = create_task!('ImageToTextTask', options)
      api_result = get_task_result!(task['taskId'])

      task_result = AntiCaptcha::TaskResult.new(
        task_id:           task['taskId'],
        error_id:          api_result['errorId'],
        error_code:        api_result['errorCode'],
        error_description: api_result['errorDescription'],
        status:            api_result['status'],
        cost:              api_result['cost'],
        ip:                api_result['ip'],
        create_time:       api_result['createTime'],
        end_time:          api_result['endTime'],
        solve_count:       api_result['solveCount']
      )

      return AntiCaptcha::ImageToTextSolution.new(
        api_response: api_result,
        task_result:  task_result,
        url:          api_result['solution']['url'],
        text:         api_result['solution']['text']
      )
    end

    #
    # Decodes a NoCaptcha CAPTCHA.
    #
    # @see `AntiCaptcha::Client#decode_nocaptcha!`
    #
    def decode_nocaptcha(options, proxy = nil)
      decode_nocaptcha!(options, proxy)
    rescue
      AntiCaptcha::NoCaptchaSolution.new
    end

    #
    # Decodes a NoCaptcha CAPTCHA.
    #
    # @param [Hash] options Options hash.
    #   @option options [String]  :website_url
    #   @option options [String]  :website_key
    #   @option options [String]  :language_pool
    #
    # @param [Hash] proxy Not mandatory. A hash with configs of the proxy that
    #                     has to be used. Defaults to `nil`.
    #   @option proxy [String]  :proxy_type
    #   @option proxy [String]  :proxy_address
    #   @option proxy [String]  :proxy_port
    #   @option proxy [String]  :proxy_login
    #   @option proxy [String]  :proxy_login
    #   @option proxy [String]  :proxy_password
    #   @option proxy [String]  :user_agent
    #
    # @return [AntiCaptcha::NoCaptchaSolution] The solution of the NoCaptcha.
    #
    def decode_nocaptcha!(options, proxy = nil)
      started_at = Time.now

      if proxy.nil?
        task_type = 'NoCaptchaTaskProxyless'
        hsh       = options
      else
        task_type = 'NoCaptchaTask'
        hsh       = options.merge(proxy)
      end

      task = create_task!(task_type, hsh)
      api_result = get_task_result!(task['taskId'])

      task_result = AntiCaptcha::TaskResult.new(
        task_id:           task['taskId'],
        error_id:          api_result['errorId'],
        error_code:        api_result['errorCode'],
        error_description: api_result['errorDescription'],
        status:            api_result['status'],
        cost:              api_result['cost'],
        ip:                api_result['ip'],
        create_time:       api_result['createTime'],
        end_time:          api_result['endTime'],
        solve_count:       api_result['solveCount']
      )

      return AntiCaptcha::NoCaptchaSolution.new(
        api_response:             api_result,
        task_result:              task_result,
        g_recaptcha_response:     api_result['solution']['gRecaptchaResponse'],
        g_recaptcha_response_md5: api_result['solution']['gRecaptchaResponseMD5']
      )
    end

    #
    # Creates a task for solving the selected CAPTCHA type.
    #
    # @param [String] type The type of the CAPTCHA.
    # @param [Hash] options Options hash.
    #   # Image to text CAPTCHA
    #   @option options [String] :body64 File body encoded in base64. Make sure to
    #                                    send it without line breaks.
    #   @option options [Boolean] :phrase If the worker must enter an answer
    #                                     with at least one "space".
    #   @option options [Boolean] :case If the answer must be entered with case
    #                                   sensitivity.
    #   @option options [Integer] :numeric 0 - no requirements; 1 - only numbers
    #                                      are allowed; 2 - any letters are
    #                                      allowed except numbers.
    #   @option options [Boolean] :math If the answer must be calculated.
    #   @option options [Integer] :min_length Defines minimum length of the
    #                                         answer. 0 - no requirements.
    #   @option options [Integer] :max_length Defines maximum length of the
    #                                         answer. 0 - no requirements.
    #   # NoCaptcha
    #   @option options [String]  :website_url Address of target web page.
    #   @option options [String]  :website_key Recaptcha website key.
    #   @option options [String]  :language_pool
    #   @option options [String]  :proxy_type
    #   @option options [String]  :proxy_address
    #   @option options [String]  :proxy_port
    #   @option options [String]  :proxy_login
    #   @option options [String]  :proxy_login
    #   @option options [String]  :proxy_password
    #   @option options [String]  :user_agent
    #
    # @return [Hash] Information about the task.
    #
    def create_task!(type, options)
      args = {
        languagePool: (options[:language_pool] || 'en'),
        softId: '859'
      }

      case type
      when 'ImageToTextTask'
        args[:task] = {
          type:      'ImageToTextTask',
          body:      options[:body64],
          phrase:    options[:phrase],
          case:      options[:case],
          numeric:   options[:numeric],
          math:      options[:math],
          minLength: options[:min_length],
          maxLength: options[:max_length]
        }

      when 'NoCaptchaTaskProxyless'
        args[:task] = {
          type:       'NoCaptchaTaskProxyless',
          websiteURL: options[:website_url],
          websiteKey: options[:website_key]
        }

      when 'NoCaptchaTask'
        args[:task] = {
          type:          'NoCaptchaTask',
          websiteURL:    options[:website_url],
          websiteKey:    options[:website_key],
          proxyType:     options[:proxy_type],
          proxyAddress:  options[:proxy_address],
          proxyPort:     options[:proxy_port],
          proxyLogin:    options[:proxy_login],
          proxyPassword: options[:proxy_password],
          userAgent:     options[:user_agent]
        }

      else
        message = "Invalid task type: '#{type}'. Allowed types: " +
          "#{%w(ImageToTextTask NoCaptchaTaskProxyless NoCaptchaTask).join(', ')}"
        raise AntiCaptcha.raise_error(message)
      end

      request('createTask', args)
    end

    #
    # Creates a task for solving the selected CAPTCHA type.
    #
    # @param [String] task_id The ID of the CAPTCHA task.
    #
    # @return [Hash] Information about the task.
    #
    def get_task_result!(task_id)
      raise AntiCaptcha.raise_error('taskId not received from Anti Captcha.') unless task_id

      loop do
        api_result = request('getTaskResult', { taskId: task_id })
        return api_result if api_result['status'] == 'ready'

        sleep(polling)
        raise AntiCaptcha::Timeout if (Time.now - started_at) > timeout
      end
    end

    #
    # Retrieves account balance.
    #
    # @return [Hash] Information about the account balance.
    #
    def get_balance!
      request('getBalance')
    end

    #
    # This method allows you to define if it is a suitable time to upload new
    # tasks.
    #
    # @param [String] queue_id The ID of the queue. Options:
    #                          1 - standart ImageToText, English language.
    #                          2 - standart ImageToText, Russian language.
    #                          5 - Recaptcha NoCaptcha tasks.
    #                          6 - Recaptcha Proxyless task.
    #
    # @return [Hash] Information about the queue.
    #
    def get_queue_stats!(queue_id)
      args = { queueId: queue_id }
      request('getQueueStats', args)
    end

    #
    # Complaints are accepted only for image CAPTCHAs. A complaint is checked by
    # 5 workers, 3 of them must confirm it.
    #
    # @param [String] task_id The ID of the CAPTCHA task.
    #
    # @return [Hash] Information about the complaint.
    #
    def report_incorrect_image_catpcha!(task_id)
      args = { taskId: task_id }
      request('getTaskResult', args)
    end

    #
    # Private methods.
    #
    private

    #
    # Performs an HTTP request to the Anti Captcha API.
    #
    # @param [String] action  API method name.
    # @param [Hash]   payload Data to be sent through the HTTP request.
    #
    # @return [String] Response from the Anti Captcha API.
    #
    def request(action, payload = nil)
      payload ||= {}

      response = AntiCaptcha::HTTP.post_request(
        url: BASE_URL.gsub(':action', action),
        timeout: self.timeout,
        json_payload: payload.merge(clientKey: self.client_key).to_json
      )

      response = JSON.load(response)
      validate_response(response)

      response
    end

    #
    # Validates the response from Anti Captcha API.
    #
    # @param [Hash] response The response from Anti Captcha API.
    #
    # @raise [AntiCaptcha::Error] if Anti Captcha API responds with an error.
    #
    def validate_response(response)
      if response['errorId'].to_i > 0
        raise AntiCaptcha.raise_error(response['errorId'],
          response['errorCode'], response['errorDescription'])
      end
    end

    # Loads a CAPTCHA raw content encoded in base64 from options.
    #
    # @param [Hash] options Options hash.
    #   @option options [String]  :path   File path of the image to be decoded.
    #   @option options [File]    :file   File instance with image to be decoded.
    #   @option options [String]  :body   Binary content of the image to bedecoded.
    #   @option options [String]  :body64 Binary content encoded in base64 of the
    #                                     image to be decoded.
    #
    # @return [String] The binary image base64 encoded.
    #
    def load_captcha(options)
      if options[:body64]
        options[:body64]
      elsif options[:body]
        Base64.encode64(options[:body])
      elsif options[:file]
        Base64.encode64(options[:file].read)
      elsif options[:path]
        Base64.encode64(File.open(options[:path], 'rb').read)
      else
        raise AntiCaptcha::ArgumentError.new('Illegal image format.')
      end
    rescue
      raise AntiCaptcha::Error
    end
  end
end
