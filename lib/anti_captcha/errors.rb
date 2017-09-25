module AntiCaptcha
  #
  # This is the base AntiCaptcha exception class. Rescue it if you want to
  # catch any exception that might be raised.
  #
  class Error < Exception
  end

  class ArgumentError < Error
  end

  class Timeout < Error
  end

  def self.raise_error(error_id, error_code, error_description)
    message = "ID: #{error_id} | CODE: #{error_code} | #{error_description}"
    raise AntiCaptcha::Error.new(message)
  end
end
