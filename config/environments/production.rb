Rails.configuration.tmp_dir = '/tmp'
Rails.configuration.cplex_lib = "bin/cplex/cplex/bin/x86-64_sles10_4.1/"
Rails.configuration.gurobi_lic = "config/gurobi.lic"
Rails.configuration.java_dir = "java" 

Spliddit::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.eager_load = false

  config.secret_key_base = ENV['AWS_SECRET']
    
  # rate limiting -- using app memory so this doesn't scale to multiple nodes or many users...
  # config.middleware.use RateLimiting do |r|
  #   r.define_rule(:match => '/apps/.*/create', :type => :fixed, :metric => :rpd, :limit => 10, :per_ip => true)
  #   r.define_rule(:match => '/.*', :type => :fixed, :metric => :rph, :limit => 50000, :per_ip => true)
  #   r.define_rule(:match => '/submit-feedback', :type => :fixed, :metric => :rph, :limit => 5, :per_ip => true)
  # end

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  config.assets.precompile += %w( legacy/legacy.min.js )
  config.assets.precompile += %w( modern/modern.min.js )

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.action_mailer.delivery_method = :ses

  # Change to http://www.spliddit.org for launch
  config.action_mailer.default_url_options = { :host => "spliddit.org" }

  # Prevent Mass Assignment Security Error
  #config.active_record.mass_assignment_sanitizer = :logger

  # config.after_initialize do 
  #   Delayed::Job.scaler = :heroku_cedar
  # end
end
