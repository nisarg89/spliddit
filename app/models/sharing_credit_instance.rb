class SharingCreditInstance < Instance

  def run(attempt)
    # construct map from resource id to agent id
    m = Hash.new
    resources.each do |r|
      m[r.id] = agents.find_by_name(r.name).id
    end

    # construct r matrices
    r = Hash.new
    agents.each do |a|
      r[a.id] = Hash.new
      a.valuations.each do |i|
        r[a.id][m[i.resource_id]] = Hash.new
        a.valuations.each do |j|
          r[a.id][m[i.resource_id]][m[j.resource_id]] = i.value / j.value
        end
      end
    end

    assignments.delete_all
    if agents.count == 3
      agent_arr = []
      agents.each {|a| agent_arr << a}
      
      a = Assignment.new(ownership: 1.0 / (1 + r[agent_arr[1]][agent_arr[2]][agent_arr[0]] + r[agent_arr[2]][agent_arr[1]][agent_arr[0]]))
      a.agent_id = agent_arr[0].id
      a.instance_id = id
      a.save

      a = Assignment.new(ownership: 1.0 / (1 + r[agent_arr[2]][agent_arr[0]][agent_arr[1]] + r[agent_arr[0]][agent_arr[2]][agent_arr[1]]))
      a.agent_id = agent_arr[1].id
      a.instance_id = id
      a.save

      a = Assignment.new(ownership: 1.0 / (1 + r[agent_arr[0]][agent_arr[1]][agent_arr[2]] + r[agent_arr[1]][agent_arr[0]][agent_arr[2]]))
      a.agent_id = agent_arr[2].id
      a.instance_id = id
      a.save

    else
      agents.each do |agent|
        a = Assignment.new(ownership: exact_anon(agent.id, r))
        a.agent_id = agent.id
        a.instance_id = id
        a.save
      end
    end
  end

  def min_agents
    3
  end

  def max_agents
    100
  end

  def min_resources
    3
  end

  def max_resources
    100
  end

  def resource_types
    ['']
  end

  def valuations_sum
    100
  end

  def decimal_valuations
    false
  end

  def min_bid
    1
  end

  private
    # average of the r_ij's
    def avg(r, i, j, except)
      total = 0.0
      denom = 0
      r.each do |evaluator, evaluations|
        next if evaluator==i || evaluator==j || evaluator==except
        total += evaluations[i][j]
        denom += 1
      end
      total.to_f / denom
    end

    # de Clippel Eqs. 14-15
    def feas_inexact(i, j, r)
      if i==j
        denom = 1.0
        r.keys.each do |k|
          next if k==j
          denom += avg(r, k, j, -1)
        end
      else
        denom = 1.0
        denom += avg(r, j, i, -1)
        r.keys.each do |k|
          next if k==i || k==j
          denom += avg(r, k, i, j)
        end
      end
      1.0 / denom
    end

    # de Clippel Eq. 16
    def exact(i, j, r)
      if i==j
        total = 1.0
        r.keys.each do |k|
          next if k==j
          total -= feas_inexact(k, j, r)
        end
      else
        total = feas_inexact(i, j, r)
      end
      total
    end

    # de Clippel Eq. 17
    def exact_anon(i, r)
      numerator = 0.0
      r.keys.each do |j|
        numerator += exact(i, j, r)
      end
      numerator / r.count.to_f
    end
end
