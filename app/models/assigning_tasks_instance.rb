class AssigningTasksInstance < Instance

  def run(attempt)
    fname = "#{Rails.configuration.tmp_dir}/#{id}.txt"

    # build temp file for calling Java program
    File.delete(fname) if File.exist?(fname)
    File.open(fname, 'w+') do |f|
      # first line is number of agents, second line is number of items
      f.write("#{agents.count.to_s}\n")
      f.write("#{resources.count.to_s}\n")

      # for each item, write quantity
      resources.each do |r|
        f.write("#{r.id} #{r.quantity}\n")
      end

      # valuations
      valuations.each do |v|
        f.write("#{v.agent_id} #{v.resource_id} #{v.value}\n")
      end
    end

    # call Java
    allocation_str = `#{Rails.configuration.java_dir} -Djava.library.path=#{Rails.configuration.cplex_lib} -jar bin/tasks.jar #{fname}`

    if allocation_str.include? "failure"
      raise Error
    end

    utility = 0.0

    # create assignments
    assignments.delete_all
    allocation_str.each_line do |line|
      assignment_arr = line.split
      if assignment_arr[0] == "utility"
        utility = assignment_arr[1]
      end
      next unless assignment_arr.count == 4
      a = Assignment.new(ownership: assignment_arr[3].to_i)
      a.agent_id = assignment_arr[0].to_i
      a.resource_id = assignment_arr[1].to_i
      a.instance_id = id
      a.save

    end
    raise Error if assignments.count == 0

    equitability_notes(utility)
  end

  def equitability_notes(utility)
    agents.each do |a|
      str = "The distribution of tasks is equitable: each of the #{agents.count} participants was assigned tasks that they believed to be approximately #{sprintf("%0.02f", utility)}% of the total work, according to the submitted evaluations."
      a.update_attribute(:fairness_str, str)
    end
  end


  def max_task
    resources.sort_by {|r| r.quantity }.last
  end

  # validators
  def min_agents
    2
  end

  def max_agents
    15
  end

  def min_resources
    2
  end

  def max_resources
    100
  end

  def resource_types
    []
  end

  def valuations_sum
    100
  end

  def decimal_valuations
    true
  end

  def min_bid
    -1000
  end
end