module AntiCaptcha
  class HCaptchaSolution < AntiCaptcha::Solution
    attr_accessor :g_recaptcha_response # Deprecated
    attr_accessor :token


    def initialize(task_result = nil)
      super

      if task_result
        @token = task_result.api_result['solution']['gRecaptchaResponse']
        @g_recaptcha_response = token
      end
    end
  end
end
