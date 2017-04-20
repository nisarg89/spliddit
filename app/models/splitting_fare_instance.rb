class SplittingFareInstance < Instance

  attr_accessible :pickup_address, :total_fare, :currency, :error_message

  validates :pickup_address, presence: true, length: {minimum: 1, maximum: 100}

  validates :total_fare, numericality: {greater_than_or_equal: 0.0, less_than: 100000.0}, allow_nil: true
  validates :currency, length: { minimum: 3, maximum: 4}, allow_nil: true

  def run(attempt)
    # setup

    #Delayed::Worker.logger = Logger.new(File.join(Rails.root,'log','fare.log'))

    addresses = Hash.new
    agents.each do |a|
      addresses[a.id] = Hash.new
      addresses[a.id][:lat] = a.name.split("::")[1]
      addresses[a.id][:long] = a.name.split("::")[2]
    end

    # get TFF entity before computing any fares
    pickup_lat = pickup_address.split("::")[1]
    pickup_long = pickup_address.split("::")[2]
    uri = URI.parse("https://api.taxifarefinder.com/entity?key=#{TFF_API_KEY}&location=#{pickup_lat},#{pickup_long}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = JSON.parse(http.request(Net::HTTP::Get.new(uri.request_uri)).body)
    raise Error unless tff_check_response(response)
    entity_handle = response["handle"]

    # compute flat_fare and currency
    uri = tff_uri(entity_handle, pickup_lat, pickup_long, addresses[agents.first.id][:lat], addresses[agents.first.id][:long])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = JSON.parse(http.request(Net::HTTP::Get.new(uri.request_uri)).body)
    raise Error unless tff_check_response(response)
    flat_fare = response["initial_fare"].to_f
    if !currency
      update_attribute(:currency, response["currency"]["int_symbol"].downcase)
    end

    # compute all pairs fares
    fares = all_pairs_fares_parallel(addresses, entity_handle, pickup_lat, pickup_long)

    # compute shapley values
    shapley_sum = 0.0
    shapley = Hash.new
    agents.each do |a|
      shapley[a.id] = 0.0
    end
    agents.map {|a| a.id}.permutation.each do |perm|
      agents.each do |a|
        idx = perm.index(a.id)
        if idx == 0
          shapley[a.id] += fares[a.id][:pickup]
        else
          Delayed::Worker.logger.debug("Before This")
          shapley[a.id] += get_route_fare(fares, perm[0..idx], flat_fare).first - get_route_fare(fares, perm[0..(idx-1)], flat_fare).first
          Delayed::Worker.logger.debug("After This")
        end
      end
    end

    # denominator is (# agents) factorial
    n_fact = (1..(agents.count)).inject(:*)
    agents.each do |a|
      shapley[a.id] /= n_fact
      shapley_sum += shapley[a.id]
    end

    # compute shortest route
    shortest_route = get_route_fare(fares, agents.map {|a| a.id}, flat_fare).second

    # create assignments
    assignments.delete_all
    agents.each do |a|
      if total_fare
        # user specified the total fare, so scale everything appropriately
        assignment = Assignment.new(price: shapley[a.id] * total_fare / shapley_sum, order: shortest_route.index(a.id))
      else
        assignment = Assignment.new(price: shapley[a.id], order: shortest_route.index(a.id))
      end
      assignment.agent_id = a.id
      assignment.instance_id = id
      assignment.save
    end

    #Delayed::Worker.logger.debug("Done Assignment")
  end


  def all_pairs_fares_sequential(addresses, entity_handle, pickup_lat, pickup_long)
    fares = Hash.new
    agents.each do |a|
      fares[a.id] = Hash.new
    end
    agents.each do |a1|
      # compute fare from pickup location to address
      uri = tff_uri(entity_handle, pickup_lat, pickup_long, addresses[a1.id][:lat], addresses[a1.id][:long])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = JSON.parse(http.request(Net::HTTP::Get.new(uri.request_uri)).body)
      raise Error unless tff_check_response(response)
      fares[a1.id][:pickup] = response["total_fare"]

      agents.each do |a2|
        # check if same address (i.e. a1 == a2 or a1, a2 have same address)
        if addresses[a1.id][:lat] == addresses[a2.id][:lat] && addresses[a1.id][:long] == addresses[a2.id][:long]
          fares[a1.id][a2.id] = 0.0
        elsif a1.id < a2.id
          # a2.id < a1.id handled by symmetry
          uri = tff_uri(entity_handle, addresses[a1.id][:lat], addresses[a1.id][:long], addresses[a2.id][:lat], addresses[a2.id][:long])
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          response = JSON.parse(http.request(Net::HTTP::Get.new(uri.request_uri)).body)
          raise Error unless tff_check_response(response)
          fares[a1.id][a2.id] = response["total_fare"]
          fares[a2.id][a1.id] = fares[a1.id][a2.id] # assumes symmetry
        end
      end
    end
    fares
  end

  def all_pairs_fares_parallel(addresses, entity_handle, pickup_lat, pickup_long)
    fares = Hash.new
    fares["pickup"] = Hash.new
    agents.each do |a|
      fares[a.id] = Hash.new
    end

    EventMachine.run do
      multi = EventMachine::MultiRequest.new

      agents.each do |a1|
        uri = tff_uri(entity_handle, pickup_lat, pickup_long, addresses[a1.id][:lat], addresses[a1.id][:long])
        multi.add "pickup_#{a1.id}".to_sym, EventMachine::HttpRequest.new(uri,use_ssl: true).get
        agents.each do |a2|
          # see if same address (either a1 = a2 or live in same place)
          if addresses[a1.id][:lat] == addresses[a2.id][:lat] && addresses[a1.id][:long] == addresses[a2.id][:long]
            fares[a1.id][a2.id] = 0.0
          elsif a1.id < a2.id
            # a2.id < a1.id handled by symmetry
            uri = tff_uri(entity_handle, addresses[a1.id][:lat], addresses[a1.id][:long], addresses[a2.id][:lat], addresses[a2.id][:long])
            multi.add "#{a1.id}_#{a2.id}".to_sym, EventMachine::HttpRequest.new(uri,use_ssl: true).get
          end
        end
      end

      multi.callback do
        multi.responses[:callback].each do |key, http|
          source = key.to_s.split("_")[0]
          dest = key.to_s.split("_")[1]

          #Delayed::Worker.logger.debug("Got source/dest")

          response = JSON.parse(http.response)
          if !tff_check_response(response)
            EventMachine.stop
            raise Error
          end
          if source == "pickup"
            fares[dest.to_i][:pickup] = response["total_fare"]
          else
            fares[source.to_i][dest.to_i] = response["total_fare"]
            fares[dest.to_i][source.to_i] = response["total_fare"]
          end
        end

        multi.responses[:errback].each do |key, response|
          EventMachine.stop
          raise Error
        end

        EventMachine.stop
      end
    end
    fares
  end

  # Use TFF to calculate fare between two latlongs
  def tff_uri(handle, lat1, long1, lat2, long2)
    URI.parse("https://api.taxifarefinder.com/fare?key=#{TFF_API_KEY}&entity_handle=#{handle}&origin=#{lat1},#{long1}&destination=#{lat2},#{long2}")
  end

  # Check TFF Response for the status code, and raise Error if needed
  def tff_check_response(response)
    if response["status"] == "OK"
      return true
    elsif response["status"] == "ERROR"
      update_attribute(:error_message, "We've encountered an error. The most likely reason is that we were unable to find a route between the given addresses.")
      return false
    elsif response["status"] == "REQUEST_LIMIT_REACHED"
      update_attribute(:error_message, "Due to heavy traffic, we have exceeded our daily quota for the TaxiFareFinder service. Sorry for the inconvenience.")
      return false
    else
      update_attribute(:error_message, "We were unable to find routes between some of the addresses listed. Please make sure you've typed the addresses correctly and try again.")
      return false
    end
  end

  # compute cheapest route cost for a set of people
  def get_route_fare(costs, subset, flat_fare)
    return 0.0 unless subset.length > 0
    # loop through all routes (i.e. permutations of the set)
    min_fare = Float::INFINITY
    min_route = subset
    subset.permutation.each do |arr|
      cur_fare = costs[arr[0]][:pickup]
      for i in 0..(arr.length - 2)
        cur_fare += costs[arr[i]][arr[i+1]]
      end
      if cur_fare < min_fare
        min_fare = cur_fare
        min_route = arr
      end
    end

    # only include the flat fare once
    min_fare -= flat_fare * (subset.length - 1)

    return min_fare, min_route
  end

  def fare
    if total_fare
      total_fare
    else
      sum = 0.0
      assignments.each do |a|
        sum += a.price
      end
      sum
    end
  end

  # validators
  def min_agents
    2
  end

  def max_agents
    6
  end

  def min_resources
    0
  end

  def max_resources
    0
  end

  def resource_types
    []
  end

  def valuations_sum
    0
  end

  def decimal_valuations
    false
  end

  def min_bid
    0
  end
end