module AntiCaptcha
  class ImageToTextSolution < AntiCaptcha::Solution
    attr_accessor :url, :text

    def initialize(task_result = nil)
      super

      if task_result
        @url  = task_result.api_result['solution']['url']
        @text = task_result.api_result['solution']['text']
      end
    end
  end
end
