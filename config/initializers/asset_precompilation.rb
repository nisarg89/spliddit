# config/initializers/asset_precompilation.rb

# Precompile assets during application startup
if defined?(Rails::Server) || defined?(Rails::Console)
    config = Rails.application.config
    config.assets.compile = true
    config.assets.precompile += %w[*.js *.css]
  
    # Precompile assets
    Rails.application.load_tasks
    Rake::Task['assets:precompile'].invoke
  end
  