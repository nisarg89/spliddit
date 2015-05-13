HOUR_CACHE = ActiveSupport::Cache::MemoryStore.new(expires_in: 3600.seconds)
MINUTE_CACHE = ActiveSupport::Cache::MemoryStore.new(expires_in: 60.seconds)