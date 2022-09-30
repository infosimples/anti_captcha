module AntiCaptcha
  class GeetestSolution < AntiCaptcha::Solution
    attr_accessor :v3, :v4

    def initialize(task_result = nil)
      super

      if task_result
        solution = task_result.api_result['solution']

        if solution['pass_token']
          @v4 = {
            'captcha_id'     => solution['captcha_id'],
            'lot_number'     => solution['lot_number'],
            'pass_token'     => solution['pass_token'],
            'gen_time'       => solution['gen_time'],
            'captcha_output' => solution['captcha_output'],
          }

        else
          @v3 = {
            'challenge' => solution['challenge'],
            'validate'  => solution['validate'],
            'seccode'   => solution['seccode'],
          }
        end
      end
    end
  end
end
