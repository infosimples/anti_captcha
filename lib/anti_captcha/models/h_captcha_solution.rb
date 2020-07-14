module AntiCaptcha
  class HCaptchaSolution < AntiCaptcha::Solution
    attr_accessor :g_recaptcha_response

    def initialize(task_result = nil)
      super

      if task_result
        @g_recaptcha_response = task_result.api_result['solution']['gRecaptchaResponse']
      end
    end
  end
end
