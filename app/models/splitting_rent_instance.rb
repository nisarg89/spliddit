class SplittingRentInstance < Instance

  attr_accessible :rent, :currency, :name, :separate_passwords, :passcode, :admin_email

  validates :rent, presence: true, numericality: { greater_than: 10, less_than: 1000000}
  validates :currency, presence: true, length: { minimum: 3, maximum: 4}

  validate :bed_count

  def run(attempt)    
    fname = "#{Rails.configuration.tmp_dir}/#{id}.txt"

    # build temp file
    File.delete(fname) if File.exist?(fname)
    File.open(fname, 'w+') do |f|
      # first line is number of agents, second line is rent
      f.write("#{agents.count.to_s}\n")
      f.write("#{rent.to_s}\n")

      # valuations
      valuations.each do |v|
        case v.resource.rtype
          when "single"
            occupancy = 1
          when "double"
            occupancy = 2
          when "triple"
            occupancy = 3
          else
            occupancy = 4
        end
        occupancy.times do |i|
          f.write("#{v.agent_id} #{v.resource_id}_#{i} #{v.value / occupancy} \n")
        end
      end
    end

    # call Python
    allocation_str = `GRB_LICENSE_FILE=#{Rails.configuration.gurobi_lic} python3 lib/rent_division/rent_wrapper.py #{fname}`

    if allocation_str.include? "failure"
      raise Error
    end

    # create assignments
    assignments.delete_all
    allocation_str.each_line do |line|
      assignment_arr = line.split
      next unless assignment_arr.count == 3
      a = Assignment.new(price: assignment_arr[2].to_f)
      a.agent_id = assignment_arr[0].to_i
      a.resource_id = assignment_arr[1].split("_")[0].to_i
      a.instance_id = id
      a.save
    end
    raise Error if assignments.count != agents.count
    
    # Generate fairness messages
    ef_notes

  end

  def ef_notes
    price_for = Hash.new
    assigned_room = Hash.new

    agents.each do |agent|
      assignment = agent.assignments.first
      price_for[assignment.resource.id] = assignment.price
      assigned_room[assignment.agent_id] = assignment.resource
    end

    bid_for = Hash.new
    agents.each do |agent|
      bid_for[agent.id] = Hash.new
      agent.valuations.each do |valuation|
        case valuation.resource.rtype
          when "single"
            bid_for[agent.id][valuation.resource_id] = valuation.value
          when "double"
            bid_for[agent.id][valuation.resource_id] = valuation.value / 2
          when "triple"
            bid_for[agent.id][valuation.resource_id] = valuation.value / 3
          else
            bid_for[agent.id][valuation.resource_id] = valuation.value / 4
        end
      end
    end

    agents.each do |agent|
      room = assigned_room[agent.id]
      price = price_for[room.id]
      bid = bid_for[agent.id][room.id]
      net = bid - price
      str = "Why is my assignment envy free? "
      str += "You were assigned the room called '#{room.name}' for #{currency_sym}#{sprintf '%.2f', price}. "
      str += "Since you valued the room at #{currency_sym}#{sprintf '%.2f', bid}, you gained #{currency_sym}#{sprintf '%.2f', net}. "

      # Don't duplicate rooms
      already_shown = Hash.new
      already_shown.default = false
      already_shown[room.id] = true
      agents.each do |other_agent|
        next if agent.id == other_agent.id
        other_room = assigned_room[other_agent.id]
        next if already_shown[other_room.id]
        already_shown[other_room.id] = true
        other_price = price_for[other_room.id]
        other_bid = bid_for[agent.id][other_room.id]
        other_net = other_bid - other_price
        str += "You valued the room called '#{other_room.name}' at #{currency_sym}#{sprintf '%.2f', other_bid}. Since this room costs #{currency_sym}#{sprintf '%.2f', other_price}, "
        if other_net > 0.0
          if other_net >= net
            str += "you would have also gained #{currency_sym}#{sprintf '%.2f', other_net}. "
          else
            str += "you would have only gained #{currency_sym}#{sprintf '%.2f', other_net}. "
          end
        elsif other_net == 0.0
          str += "you would have broken even. "
        else
          str += "you would have lost #{currency_sym}#{sprintf '%.2f', (-1*other_net)}. "
        end
        agent.update_attribute(:fairness_str, str)
      end
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
    1
  end

  def max_resources
    15
  end

  def resource_types
    ['single', 'double', 'triple', 'quad']
  end

  def bed_count
    bed_ct = 0
    resources.each do |r|
      case r.rtype
      when 'single'
        bed_ct += 1
      when 'double'
        bed_ct += 2
      when 'triple'
        bed_ct += 3
      else
        bed_ct += 4
      end
    end
    if bed_ct != agents.size
      errors.add(:resources, "- the number of beds must equal the number of roommates")
    end      
  end

  def valuations_sum
    rent
  end

  def decimal_valuations
    false
  end

  def min_bid
    0
  end
end
