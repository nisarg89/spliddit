class DividingGoodsInstance < Instance
  def run(attempt)
    #Delayed::Worker.logger = Logger.new(File.join(Rails.root,'log','goods.log'))
    assignments.delete_all
    fname = "#{Rails.configuration.tmp_dir}/#{id}.txt"

    # build temp file for calling Java program
    File.delete(fname) if File.exist?(fname)
    File.open(fname, 'w+') do |f|
      # first line is number of agents, second line is number of items
      f.write("#{agents.count.to_s}\n")
      f.write("#{resources.count.to_s}\n")

      # for each item, write whether divisible or indivisible
      resources.each do |r|
        f.write("#{r.id} #{r.rtype}\n")
      end

      # valuations
      valuations.each do |v|
        f.write("#{v.agent_id} #{v.resource_id} #{v.value.to_i}\n")
      end
    end

    # call the MNW algorithm
    allocation_str = ""
    if Gem.win_platform? 
      # Windows --> just run bin/goods.exe with instance file. 
      allocation_str = `bin/goods #{fname}`
    else
      # Linux (Amazon EC2) --> run bin/run_goods.sh with path to MCR and instance file.
      # Multiple commands to prevent Mass Assignment Security Error
      #FileUtils.chmod "u=wrx,go=rx", 'bin/run_goods.sh'
      FileUtils.chmod "u=wrx,go=rx", 'bin/goods'
      my_mcrroot = "/home/webapp/MCR/INST/v85"
      lib_path = ".:#{my_mcrroot}/runtime/glnxa64:#{my_mcrroot}/bin/glnxa64:#{my_mcrroot}/sys/os/glnxa64:#{my_mcrroot}/sys/opengl/lib/glnxa64"
      ENV["LD_LIBRARY_PATH"] = lib_path
      ENV["PATH"] = ENV["PATH"] + ":" + lib_path
      ENV["MCR_CACHE_ROOT"]="/tmp"
      allocation_str = `bin/goods #{fname}`
      #allocation_str = `bin/run_goods.sh /home/webapp/MCR/INST/v85 #{fname}`
    end
    raise Error if allocation_str.include? "failure"

    # create assignments
    allocation_str.each_line do |line|
      assignment_arr = line.split
      next unless assignment_arr.count == 3
      a = Assignment.new(ownership: assignment_arr[2].to_f)
      a.agent_id = assignment_arr[0].to_i
      a.resource_id = assignment_arr[1].to_i
      a.instance_id = id
      a.save
    end
    raise Error if assignments.count == 0

    # Generate fairness messages
    ef_notes
  end

  # Compute how much each agent values his own bundle
  def own_bundle_val
    own_bundle_value = Hash.new
    own_bundle_value.default = 0.0
    agents.each do |agent|
      agent.assignments.each do |assignment|
        own_bundle_value[agent.id] += agent.valuations.find_by_resource_id(assignment.resource_id).value * assignment.ownership
      end
    end
    return own_bundle_value
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
        other_agent.assignments.each do |assignment|
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
    own_bundle_value = own_bundle_val()
    other_bundle_values, other_bundle_total_value = other_bundle_vals()
    is_ef = true;
    other_bundle_remove_item = Hash.new
    other_bundle_net_value = Hash.new
    
    # Determine if the allocation is completely EF for all players
    agents.each do |agent|
      break unless is_ef
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        if other_bundle_total_value[agent.id][other_agent.id] > own_bundle_value[agent.id] + 0.01
          is_ef = false
          break
        end
      end
    end

    # If it's not EF, find the item to remove, and the net values after removing it
    if !(is_ef)
      agents.each do |agent|
        other_bundle_remove_item[agent.id] = Hash.new
        other_bundle_remove_item[agent.id].default = -1
        other_bundle_net_value[agent.id] = Hash.new
        other_bundle_net_value[agent.id].default = 0.0
        agents.each do |other_agent|
          next if agent.id == other_agent.id
          h = other_bundle_values[agent.id][other_agent.id]
          if h.empty?
            removed_resource_id = -1
          else
            removed_resource_id = h.max_by{ |k, v| v }[0]
          end
          other_bundle_remove_item[agent.id][other_agent.id] = removed_resource_id
          if removed_resource_id != -1 # other player does not have any items at all
            frac = resources.find(removed_resource_id).rtype == 'divisible' ? 0.01 : 1
            v = agent.valuations.find_by_resource_id(removed_resource_id).value
            other_bundle_net_value[agent.id][other_agent.id] = other_bundle_total_value[agent.id][other_agent.id] - v * frac
          else
            other_bundle_net_value[agent.id][other_agent.id] = other_bundle_total_value[agent.id][other_agent.id]
          end
        end
      end
    end

    agents.each do |agent|
      str = "We were able to find "
      if is_ef
        str += "an envy-free division. "
      else
        str += "a division that is envy free up to one good. "
      end
      str += "You assigned a total of #{sprintf '%.2f', own_bundle_value[agent.id]} points to your items (out of 1000 points). "
      str += "In comparison, you assigned "
      i = 0
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        i += 1
        if is_ef
          str += "#{sprintf '%.2f', other_bundle_total_value[agent.id][other_agent.id]} points to #{other_agent.name}'s items"
        else
          str += "#{sprintf '%.2f', other_bundle_net_value[agent.id][other_agent.id]} points to #{other_agent.name}'s items"
          if other_bundle_remove_item[agent.id][other_agent.id] != -1
            r = resources.find(other_bundle_remove_item[agent.id][other_agent.id])
            str += " after removing "
            if r.rtype == 'divisible'
              str += "1% of "
            end
            str += "the item \"#{r.name}\""
          end
        end
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

  # validators
  def min_agents
    2
  end

  def max_agents
    20
  end

  def min_resources
    2
  end

  def max_resources
    100
  end

  def resource_types
    ['divisible', 'indivisible']
  end

  def valuations_sum
    1000
  end

  def decimal_valuations
    false
  end

  def min_bid
    0
  end
end