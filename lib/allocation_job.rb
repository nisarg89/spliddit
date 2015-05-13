class AllocationJob < Struct.new(:id)

  def perform
    Instance.find(id).run(@job.attempts + 1)
  end

  def max_attempts
    1
  end

  def max_run_time
    instance = Instance.find(id)
    if instance.application.abbr == 'credit'
      5.seconds
    elsif instance.application.abbr == 'rent'
      10.seconds
    elsif instance.application.abbr = 'fare'
      60.seconds
    else
      (instance.resources.count+3).seconds
    end
  end

  def default_queue_name
    "algorithms"
  end

  def before(job)
    @job = job
  end

  def success(job)
    instance = Instance.find(id)
    instance.update_attribute(:status, "complete")
    Delayed::Job.enqueue(ResultsEmailJob.new(id))
  end

  def error(job, exception)
    # don't set failure so that if refresh link will see error
    # instance = Instance.find(id)
    # instance.update_attribute(:status, "failure")
  end

  def failure(job)
    instance = Instance.find(id)
    instance.update_attribute(:status, "failure")
    Delayed::Job.enqueue(ResultsEmailJob.new(id))
  end

end