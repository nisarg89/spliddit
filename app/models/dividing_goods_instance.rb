class DividingGoodsInstance < Instance

  def run(attempt)
    if attempt > 3
      raise Error
    end
    assignments.delete_all
    if agents.count == 2
      run_adjusted_winner
    else
      run_highest_level_fairness(attempt)
    end
  end

  # Algorithm for 2 players
  def run_adjusted_winner
    player1 = agents.first.id
    player2 = agents.last.id
    player1_points = 0.0
    player2_points = 0.0

    # create valuation matrix
    v = Hash.new
    resources.each { |r| v[r.id] = Hash.new }
    valuations.each { |val| v[val.resource.id][val.agent.id] = val.value }

    # tracks assignment for each resource
    assignment_for = Hash.new
    resources.each do |r| 
      assignment_for[r.id] = Assignment.new(ownership: 1.0)
      assignment_for[r.id].resource_id = r.id
      assignment_for[r.id].instance_id = id

      # assign each item to the highest bidder
      if v[r.id][player1] >= v[r.id][player2]
        assignment_for[r.id].agent_id = player1
        player1_points += v[r.id][player1]
      else
        assignment_for[r.id].agent_id = player2
        player2_points += v[r.id][player2]
      end
    end

    # Begin "adjusted" part of adjusted winner
    # let player_a be the player with more points, player_b with fewer
    if player1_points >= player2_points
      player_a = player1
      player_b = player2
      player_a_points = player1_points
      player_b_points = player2_points
    else
      player_a = player2
      player_b = player1
      player_a_points = player2_points
      player_b_points = player1_points
    end

    v.sort_by { |r, h| -h[player_b] / [0.001, h[player_a]].max }.each do |p|
      # Check if "adjusted" phase is over
      break if player_a_points == player_b_points

      resource = p.first
      player_a_val = p.second[player_a]
      player_b_val = p.second[player_b]

      # Can't transfer goods from a to b if belongs to b
      next if assignment_for[resource].agent_id == player_b

      if (player_a_points - player_a_val > player_b_points + player_b_val)
        # give entire item to player b
        assignment_for[resource].agent_id = player_b
        player_b_points += player_b_val
        player_a_points -= player_a_val
      elsif (player_a_points - player_a_val < player_b_points + player_b_val)
        # give some of item to player b and stop the process
        # solve equation player_a_points - player_a_val*x = player_b_points + player_b_val*x
        x = (player_a_points - player_b_points) / (player_a_val + player_b_val)
        assignment_for[resource].ownership = 1 - x

        a = Assignment.new(ownership: x)
        a.resource_id = resource
        a.instance_id = id
        a.agent_id = player_b
        a.save unless a.ownership < 0.001

        player_b_points += player_b_val*x
        player_a_points -= player_a_val*x
      else
        # same number of points if transfer
        assignment_for[resource].agent_id = player_b
        player_b_points += player_b_val
        player_a_points -= player_a_val
      end
    end

    # Save the assignments
    resources.each do |r|
      a = assignment_for[r.id]
      a.ownership = 1.0 if a.ownership > 0.999
      a.save
    end

    # Generate equitability fairness strings
    equitable_notes(player_a_points)
  end

  # Algorithm for 3 or more players
  # Tries to find an envy-free allocation. If it fails, backtracks to
  # proportional. If that fails, backtracks to MMS fairness guarantee.
  def run_highest_level_fairness(attempt)
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

    # call Java
    if attempt == 1
      fairness_level = 'ef'
    elsif attempt == 2
      fairness_level = 'p'
    elsif attempt == 3
      fairness_level = 'ccg'
    else
      raise Error
    end

    allocation_str = `#{Rails.configuration.java_dir} -Djava.library.path=#{Rails.configuration.cplex_lib} -jar bin/goods.jar #{fname} #{fairness_level}`

    if allocation_str.include? "failure"
      run_highest_level_fairness(attempt + 1)
      return
    end

    # create assignments
    assignments.delete_all
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
    if fairness_level == 'ef'
      ef_notes
    elsif fairness_level == 'p'
      proportional_notes
    elsif fairness_level == 'ccg'
      # pull CCG data
      ccg_for = Hash.new
      ccg_multiplier = 0.0
      allocation_str.lines.each_with_index do |line, i|
        if ccg_for.count < agents.size && line.split.count == 2
          ccg_for[line.split[0].to_i] = line.split[1].to_f
        end
        if ccg_for.count == agents.size && line.split.count == 1
          ccg_multiplier = line.split[0].to_f
          break
        end
      end
      ccg_notes(ccg_multiplier, ccg_for)
    end
  end

  # Compute how much each agent values his own bundle
  def own_bundle_val
    own_bundle_value = Hash.new
    own_bundle_value.default = 0.0
    agents.each do |agent|
      agent.assignments.each do |assignment|
        v = agent.valuations.find_by_resource_id(assignment.resource_id).value
        own_bundle_value[agent.id] += v * assignment.ownership
      end
    end
    return own_bundle_value
  end

  # Compute notes to show each player when computing equitable allocations (2 players only)
  def equitable_notes(points)
    player1 = agents.first
    player2 = agents.last

    player1_str = "We were able to find an equitable division. "
    player1_str += "Both you and #{player2.name} assigned  #{sprintf '%.1f', points} points to your items (out of 1000 points). "
    if points != 500
      player1_str += "This means your allocation is envy free as well, since you only assigned #{sprintf '%.1f', (1000 - points)} points to #{player2.name}'s items."
    else
      player1_str += "This means your allocation is envy free as well, since you also assigned 500 points to #{player2.name}'s items."
    end
    player1.update_attribute(:fairness_str, player1_str)

    player2_str = "We were able to find an equitable division. "
    player2_str += "Both you and #{player1.name} assigned #{sprintf '%.1f', points} points to your items (out of 1000 points). "
    if points != 500
      player2_str += "This means your allocation is envy free as well, since you only assigned #{sprintf '%.1f', (1000 - points)} points to #{player1.name}'s items."
    else
      player2_str += "This means your allocation is envy free as well, since you also assigned 500 points to #{player1.name}'s items."
    end
    player2.update_attribute(:fairness_str, player2_str)
  end

  # Compute notes to show each agent when computing envy-free allocations
  def ef_notes
    own_bundle_value = own_bundle_val()

    other_bundle_value = Hash.new
    agents.each do |agent|
      other_bundle_value[agent.id] = Hash.new
      other_bundle_value[agent.id].default = 0.0
      agents.each do |other_agent| 
        next if agent.id == other_agent.id
        other_agent.assignments.each do |assignment|
          v = agent.valuations.find_by_resource_id(assignment.resource_id).value
          other_bundle_value[agent.id][other_agent.id] += v * assignment.ownership
        end
      end
    end

    agents.each do |agent|
      str = "We were able to find an envy-free division. "
      str += "You assigned a total of #{sprintf '%.1f', own_bundle_value[agent.id]} points to your items (out of 1000 points). "
      str += "In comparison, you assigned "
      i = 0
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        i += 1
        str += "#{sprintf '%.1f', other_bundle_value[agent.id][other_agent.id]} points to #{other_agent.name}'s items"
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

  # Compute notes to show each agent when computing proportional allocations
  def proportional_notes
    own_bundle_value = own_bundle_val()
    agents.each do |agent|
      str = "We were able to find a division satisfying proportionality. "
      str += "You assigned a total of #{sprintf '%.1f', own_bundle_value[agent.id]} points to your items (out of 1000 points). "
      str += "Since we divided the items between #{agents.count} people, your proportional share is 1000 / #{agents.count} = "
      str += "#{sprintf '%.1f',(1000.0 / agents.count)} points."
      agent.update_attribute(:fairness_str, str)
    end
  end

  # Compute notes to show each agent when computing ccg allocations
  def ccg_notes(ccg_multiplier, ccg_for)
    own_bundle_value = own_bundle_val()
    agents.each do |agent|
      if ccg_multiplier >= 1.0
        str = "We were able to find a division that guarantees everyone their full maximin share. "
      else
        str = "We were able to find a division that guarantees everyone #{(100*ccg_multiplier).to_i}% of their maximin share. "
      end
      str += "You assigned a total of #{sprintf '%.1f', own_bundle_value[agent.id]} points to your items (out of 1000 points). "
      str += "We computed that your maximin share is #{sprintf '%.1f', ccg_for[agent.id]}."
      agent.update_attribute(:fairness_str, str)
    end
  end

  # validators
  def min_agents
    2
  end

  def max_agents
    15
  end

  def min_resources
    3
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