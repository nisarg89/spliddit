# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Spliddit::Application.initialize!

# ActionMailer::Base.smtp_settings = {
#   :address        => 'smtp.sendgrid.net',
#   :port           => '587',
#   :authentication => :plain,
#   :user_name      => ENV['app14662472@heroku.com'],
#   :password       => ENV['SENDGRID_PASSWORD'],
#   :domain         => 'heroku.com',
#   :enable_starttls_auto => true
# }

# Added require statements
require 'set'
require 'munkres'
require 'breakpoint'