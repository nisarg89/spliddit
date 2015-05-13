module InstanceHelpers
  def splitting_rent_instance_builder(params)
    return false if !params[:agents_ct] || !params[:resources_ct] || !params[:rent] || 
                    !params[:instance_name] || !params[:contact_method] || 
                    !params[:currency] 
    
    case params[:contact_method]
    when 'email'
      separate_passwords = true
    when 'noemail'
      separate_passwords = false
    else
      return false
    end

    instance = SplittingRentInstance.new(
      rent: params[:rent].to_i, 
      currency: params[:currency], 
      name: params[:instance_name], 
      separate_passwords: separate_passwords,
      passcode: (0...10).map{(65+rand(26)).chr}.join,
      admin_email: params[:admin_email])
    instance.application = Application.find('rent')

    # build agents
    agent_ct = params[:agents_ct].to_i
    return false if agent_ct < 2 or agent_ct > 15 # TODO: magic numbers
    agent_ct.times do |i|
      if !separate_passwords
        a = instance.agents.build(
          name: params[:names][i.to_s.to_sym],
          passcode: (0...10).map{(65+rand(26)).chr}.join)
      else
        a = instance.agents.build(name: params[:names][i.to_s.to_sym], 
          passcode: (0...10).map{(65+rand(26)).chr}.join, 
          email: params[:emails][i.to_s.to_sym])
      end
      return false unless a.save
    end

    # build rooms
    room_ct = params[:resources_ct].to_i
    return if room_ct < 1 || room_ct > 15
    room_ct.times do |i|
      r = instance.resources.build(
        name: params[:rnames][i.to_s.to_sym], 
        rtype: params[:types][i.to_s.to_sym], 
        description: params[:descriptions][i.to_s.to_sym])
      return false unless r.save
    end      

    return false unless instance.save
    instance
  end

  def dividing_goods_instance_builder(params)
    return false if !params[:agents_ct] || !params[:resources_ct] || 
                    !params[:instance_name] || !params[:contact_method]
    
    case params[:contact_method]
    when 'email'
      separate_passwords = true
    when 'noemail'
      separate_passwords = false
    else
      return false
    end

    instance = DividingGoodsInstance.new(
      name: params[:instance_name], 
      separate_passwords: separate_passwords,
      passcode: (0...10).map{(65+rand(26)).chr}.join,
      admin_email: params[:admin_email])
    instance.application = Application.find('goods')

    # build agents
    agent_ct = params[:agents_ct].to_i
    return false if agent_ct < 2 or agent_ct > 15 # TODO: magic numbers
    agent_ct.times do |i|
      if !separate_passwords
        a = instance.agents.build(
          name: params[:names][i.to_s.to_sym],
          passcode: (0...10).map{(65+rand(26)).chr}.join)
      else
        a = instance.agents.build(name: params[:names][i.to_s.to_sym], 
          passcode: (0...10).map{(65+rand(26)).chr}.join, 
          email: params[:emails][i.to_s.to_sym])
      end
      return false unless a.save
    end

    # build resources
    items_ct = params[:resources_ct].to_i
    return if items_ct < 3 || items_ct > 100
    items_ct.times do |i|
      r = instance.resources.build(
        name: params[:rnames][i.to_s.to_sym], 
        rtype: params[:types] ? params[:types][i.to_s.to_sym] : 'indivisible', 
        description: params[:descriptions][i.to_s.to_sym])
      return false unless r.save
    end      

    return false unless instance.save
    instance
  end

  def sharing_credit_instance_builder(params)
    return false if !params[:agents_ct] || !params[:instance_name] || 
                    !params[:contact_method]
    
    case params[:contact_method]
    when 'email'
      separate_passwords = true
    when 'noemail'
      separate_passwords = false
    else
      return false
    end

    instance = SharingCreditInstance.new(
      name: params[:instance_name], 
      separate_passwords: separate_passwords,
      passcode: (0...10).map{(65+rand(26)).chr}.join,
      admin_email: params[:admin_email])
    instance.application = Application.find('credit')

    # build agents
    agent_ct = params[:agents_ct].to_i
    return false if agent_ct < 4 or agent_ct > 25 # TODO: magic numbers
    agent_ct.times do |i|
      if !separate_passwords
        a = instance.agents.build(
          name: params[:names][i.to_s.to_sym],
          passcode: (0...10).map{(65+rand(26)).chr}.join)
      else
        a = instance.agents.build(name: params[:names][i.to_s.to_sym], 
          passcode: (0...10).map{(65+rand(26)).chr}.join, 
          email: params[:emails][i.to_s.to_sym])
      end
      return false unless a.save
    end

    # build resources (which are just the agents)
    instance.agents.each do |a|
      r = instance.resources.build(name: a.name[0..99])
      return false unless r.save
    end   

    return false unless instance.save
    instance
  end

  def splitting_fare_instance_builder(params)
    instance = SplittingFareInstance.new(
      name: params[:instance_name],
      pickup_address: params[:pickup],
      separate_passwords: false,
      passcode: (0...10).map{(65+rand(26)).chr}.join,
      admin_email: params[:admin_email])
    instance.application = Application.find('fare')
    if !params[:total_fare].blank?
      instance.total_fare = params[:total_fare]
      instance.currency = params[:currency]
    end

    # build agents
    agents_ct = 0
    if !params[:address_1].blank?
      a = instance.agents.build(
        name: params[:address_1],
        passcode: (0...10).map{(65+rand(26)).chr}.join)
      return false unless a.save
      agents_ct += 1
    end

    if !params[:address_2].blank?
      a = instance.agents.build(
        name: params[:address_2],
        passcode: (0...10).map{(65+rand(26)).chr}.join)
      return false unless a.save
      agents_ct += 1
    end

    if !params[:address_3].blank?
      a = instance.agents.build(
        name: params[:address_3],
        passcode: (0...10).map{(65+rand(26)).chr}.join)
      return false unless a.save
      agents_ct += 1
    end

    if !params[:address_4].blank?
      a = instance.agents.build(
        name: params[:address_4],
        passcode: (0...10).map{(65+rand(26)).chr}.join)
      return false unless a.save
      agents_ct += 1
    end

    if !params[:address_5].blank?
      a = instance.agents.build(
        name: params[:address_5],
        passcode: (0...10).map{(65+rand(26)).chr}.join)
      return false unless a.save
      agents_ct += 1
    end

    if !params[:address_6].blank?
      a = instance.agents.build(
        name: params[:address_6],
        passcode: (0...10).map{(65+rand(26)).chr}.join)
      return false unless a.save
      agents_ct += 1
    end

    return false unless instance.save
    instance
  end

  def assigning_tasks_instance_builder(params)
    return false if !params[:agents_ct] || !params[:resources_ct] || 
                    !params[:instance_name] || !params[:contact_method]
    
    case params[:contact_method]
    when 'email'
      separate_passwords = true
    when 'noemail'
      separate_passwords = false
    else
      return false
    end

    instance = AssigningTasksInstance.new(
      name: params[:instance_name], 
      separate_passwords: separate_passwords,
      passcode: (0...10).map{(65+rand(26)).chr}.join,
      admin_email: params[:admin_email])
    instance.application = Application.find('tasks')

    # build agents
    agent_ct = params[:agents_ct].to_i
    return false if agent_ct < 2 or agent_ct > 15 # TODO: magic numbers
    agent_ct.times do |i|
      if !separate_passwords
        a = instance.agents.build(
          name: params[:names][i.to_s.to_sym],
          passcode: (0...10).map{(65+rand(26)).chr}.join)
      else
        a = instance.agents.build(name: params[:names][i.to_s.to_sym], 
          passcode: (0...10).map{(65+rand(26)).chr}.join, 
          email: params[:emails][i.to_s.to_sym])
      end
      return false unless a.save
    end

    # build resources
    items_ct = params[:resources_ct].to_i
    return false if items_ct < 2 || items_ct > 100
    items_ct.times do |i|
      r = instance.resources.build(
        name: params[:rnames][i.to_s.to_sym], 
        quantity: params[:quantities] ? params[:quantities][i.to_s.to_sym].to_i : 1,
        description: params[:descriptions][i.to_s.to_sym])
      return false unless r.save
    end      

    return false unless instance.save
    instance
  end

  # Takes in an agent and a map from resource id to bid, and constructs valuation objects
  # Returns false if there is a validation error
  def build_valuations(agent, values)
    instance = agent.instance
    value_sum = 0
    app = instance.application.abbr
    values.each do |item_id,value|

      # for sharing credit, can't evaluate yourself
      next if app == 'credit' && instance.resources.find(item_id).name == agent.name

      if instance.decimal_valuations
        value_sum += value.to_f
        v = agent.valuations.build(value: value.to_f)
      else
        value_sum += value.to_i
        v = agent.valuations.build(value: value.to_i)
      end
      v.resource = instance.resources.find(item_id)
      v.instance = agent.instance

      if !v.save!
        agent.valuations.delete_all
        return false
      end
    end
    if (value_sum - instance.valuations_sum).abs > 0.1
      agent.valuations.delete_all
      return false
    else
      agent.toggle! :submitted
      return true
    end
  end

  # Same as above, but takes in a map from resource name to bid
  def build_valuations_demo(agent, values)
    instance = agent.instance
    value_sum = 0
    app = instance.application.abbr
    values.each do |item_name,value|

      # for sharing credit, can't evaluate yourself
      next if app == 'credit' && instance.resources.find_by_name(item_name).name == agent.name

      if instance.decimal_valuations
        value_sum += value.to_f
        v = agent.valuations.build(value: value.to_f)
      else
        value_sum += value.to_i
        v = agent.valuations.build(value: value.to_i)
      end
      v.resource = instance.resources.find_by_name(item_name)
      v.instance = agent.instance

      if !v.save!
        agent.valuations.delete_all
        return false
      end
    end
    if (value_sum - instance.valuations_sum).abs > 0.1
      agent.valuations.delete_all
      return false
    else
      agent.toggle! :submitted
      return true
    end
  end
end