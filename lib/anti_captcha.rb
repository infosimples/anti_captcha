require 'base64'
require 'json'
require 'net/http'
require 'openssl'

#
# The module AntiCaptcha contains all the code for the anti_captcha gem.
# It acts as a safely namespace that isolates logic of AntiCaptcha from any
# project that uses it.
#
module AntiCaptcha
  #
  # Creates an Anti Captcha API client. This is a shortcut to
  # AntiCaptcha::Client.new.
  #
  def self.new(key, options = {})
    AntiCaptcha::Client.new(key, options)
  end

  #
  # Base class of a model object returned by AntiCaptcha API.
  #
  class Model
    def initialize(values = {})
      values.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end
end

require 'anti_captcha/http'
require 'anti_captcha/errors'
require 'anti_captcha/models/solution'
require 'anti_captcha/models/image_to_text_solution'
require 'anti_captcha/models/no_captcha_solution'
require 'anti_captcha/models/fun_captcha_solution'
require 'anti_captcha/models/task_result'
require 'anti_captcha/client'
require 'anti_captcha/version'
