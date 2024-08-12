module AntiCaptcha
  class TurnstileSolution < AntiCaptcha::Solution
    attr_accessor :token

    def initialize(task_result = nil)
      super

      if task_result
        @token = task_result.api_result['solution']['token']
      end
    end
  end
end
