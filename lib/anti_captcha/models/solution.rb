module AntiCaptcha
  class Solution < AntiCaptcha::Model
    attr_accessor :api_response, :task_result

    def initialize(task_result = nil)
      if task_result
        @api_response = task_result.api_result
        @task_result  = task_result
      end
    end
  end
end
