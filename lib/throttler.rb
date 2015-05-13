module Throttler
  def throttle_requests
    throttle(HOUR_CACHE, 'count', 1000, true)
  end

  def throttle_apps
    throttle(HOUR_CACHE, 'apps_count', 5, true)
  end

  def throttle_demos
    throttle(MINUTE_CACHE, 'demos_count', 3, false)
  end

  def throttle_feedback
    throttle(HOUR_CACHE, 'emails_count', 3, true)
  end

  def throttle_mailing_list
    throttle(HOUR_CACHE, 'emails_count', 3, false)
  end

  private
    def throttle(cache, prefix, limit, render_error)
      client_ip = request.remote_ip
      key = "#{prefix}:#{client_ip}"
      count = cache.fetch(key)

      unless count
        cache.write(key, 0)
        return true
      end

      if count.to_i >= limit
        @limited = true
        if render_error
          flash[:error] = "You've exceeded our request limit. Please try again in a little while."
          flash.keep(:error)
          render 'statuses/error'
        end
        return
      end

      cache.increment(key)
      logger.info "#{key} is now #{count}"
      true
    end
end