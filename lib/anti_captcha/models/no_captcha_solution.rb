module AntiCaptcha
  class NoCaptchaSolution < AntiCaptcha::Solution
    attr_accessor :g_recaptcha_response, :g_recaptcha_response_md5
  end
end
