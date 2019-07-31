module AntiCaptcha
  class RecaptchaV3Solution < AntiCaptcha::Solution
    attr_accessor :g_recaptcha_response, :g_recaptcha_response_md5

    def initialize(task_result = nil)
      super

      if task_result
        @g_recaptcha_response     = task_result.api_result['solution']['gRecaptchaResponse']
        @g_recaptcha_response_md5 = task_result.api_result['solution']['gRecaptchaResponseMD5']
      end
    end
  end
end
