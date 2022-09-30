module AntiCaptcha
  class TaskResult < AntiCaptcha::Model
    attr_accessor :task_id, :error_id, :error_code, :error_description, :status,
                  :cost, :ip, :create_time, :end_time, :solve_count, :api_result

    def initialize(api_result, task_id)
      @task_id = task_id

      @api_result        = api_result
      @error_id          = api_result['errorId']
      @error_code        = api_result['errorCode']
      @error_description = api_result['errorDescription']
      @status            = api_result['status']
      @cost              = api_result['cost']
      @ip                = api_result['ip']
      @create_time       = api_result['createTime']
      @end_time          = api_result['endTime']
      @solve_count       = api_result['solveCount']
    end
  end
end
