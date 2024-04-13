class AssigningTasksInstance < Instance

  def run(attempt)
    fname = "#{Rails.configuration.tmp_dir}/#{id}.txt"

    # build temp file for calling the solver
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

    # call the solver
    allocation_str = `GRB_LICENSE_FILE=#{Rails.configuration.gurobi_lic} python3 lib/task_division/task_solver_wrapper.py #{fname}`

    if allocation_str.include? "failure"
      raise Error
    end

    # create assignments
    assignments.delete_all
    allocation_str.each_line do |line|
      assignment_arr = line.split
      next unless assignment_arr.count == 3
      a = Assignment.new(ownership: assignment_arr[2].to_i)
      a.agent_id = assignment_arr[0].to_i
      a.resource_id = assignment_arr[1].to_i
      a.instance_id = id
      a.save

    end
    raise Error if assignments.count == 0

    ef_notes
  end

  # Compute how much each agent values his own bundle
  def own_bundle_val
    own_bundle_value = Hash.new(0.0)
    own_bundle_value_upto_one = Hash.new(0.0)
    own_max_task = Hash.new(nil)
    agents.each do |agent|
      max_valuation = 0.0
      agent.assignments.where(instance_id: id).each do |assignment|
       cur_valuation = agent.valuations.find_by_resource_id(assignment.resource_id).value
        own_bundle_value[agent.id] += cur_valuation * assignment.ownership
        if assignment.ownership >= 1 && cur_valuation > max_valuation
          max_valuation = cur_valuation
          own_max_task[agent.id] = assignment.resource_id
        end
      end
      own_bundle_value_upto_one[agent.id] = own_bundle_value[agent.id] - max_valuation
    end
    return own_bundle_value, own_bundle_value_upto_one, own_max_task
  end

  def total_val
    total_value = Hash.new(0.0)
    agents.each do |agent|
      resources.each do |r|
        total_value[agent.id] += agent.valuations.where(instance_id: id, resource_id: r.id).first.value * r.quantity
      end
    end
    return total_value
  end

  # Compute the values of an agent for the items (scaled by ownership) in the bundle of other agents
  def other_bundle_vals
    other_bundle_values = Hash.new
    other_bundle_total_value = Hash.new
    agents.each do |agent|
      other_bundle_values[agent.id] = Hash.new
      other_bundle_total_value[agent.id] = Hash.new
      other_bundle_total_value[agent.id].default = 0.0
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        other_bundle_values[agent.id][other_agent.id] = Hash.new
        other_bundle_values[agent.id][other_agent.id].default = 0.0
        other_agent.assignments.where(instance_id: id).each do |assignment|
          v = agent.valuations.find_by_resource_id(assignment.resource_id).value * assignment.ownership
          other_bundle_values[agent.id][other_agent.id][assignment.resource_id] = v
          other_bundle_total_value[agent.id][other_agent.id] += v
        end
      end
    end
    return other_bundle_values, other_bundle_total_value
  end


  # Compute notes to show each agent when computing envy-free allocations
  def ef_notes
    own_bundle_value, own_bundle_value_upto_one, own_max_task = own_bundle_val()
    total_value = total_val()
    other_bundle_values, other_bundle_total_value = other_bundle_vals()
    is_ef = true;
    own_bundle_remove_item = Hash.new
    own_bundle_net_value = Hash.new

    # Determine if the allocation is completely EF for all players
    agents.each do |agent|
      break unless is_ef
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        if other_bundle_total_value[agent.id][other_agent.id] < own_bundle_value[agent.id] - 0.01
          is_ef = false
          break
        end
      end
    end

    agents.each do |agent|
      str = "We were able to find "
      if is_ef
        str += "an envy-free division. "
      else
        str += "a division that is envy free up to one task. "
      end
      str += "You assigned a total of #{sprintf '%.1f', 100*own_bundle_value[agent.id]/total_value[agent.id]}% of the total work, according to your submitted evaluations."
      if !is_ef
        r = resources.find(own_max_task[agent.id])
        str += "After not having to do task \"#{r.name}\""
        if r.quantity > 1
          str += " once,"
        end
        str += " you assigned a total of #{sprintf '%.1f', 100*own_bundle_value_upto_one[agent.id]/total_value[agent.id]}% of the total work."
      end
      str += "In comparison, you assigned "
      i = 0
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        i += 1
        str += "#{sprintf '%.1f', 100*other_bundle_total_value[agent.id][other_agent.id]/total_value[agent.id]}% of the total work to #{other_agent.name}'s tasks"
        if i == agents.count-2
          str += ", and "
        elsif i == agents.count-1
          str += "."
        else
          str += ", "
        end
      end
      agent.update_attribute(:fairness_str, str)
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
