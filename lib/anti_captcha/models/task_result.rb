module AntiCaptcha
  class TaskResult < AntiCaptcha::Model
    attr_accessor :task_id, :error_id, :error_code, :error_description, :status,
    :cost, :ip, :create_time, :end_time, :solve_count
  end
end
