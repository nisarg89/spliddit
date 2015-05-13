namespace :eb do
  def eb_deployer_env
    ENV['EB_DEPLOYER_ENV'] || 'dev'
  end

  def eb_deployer_package
    name = File.basename(Dir.pwd).downcase.gsub(/[^0-9a-z]/, '-').gsub(/--/, '-')
    "tmp/#{name}.zip"
  end

  desc "Remove the package file we generated."
  task :clean do
    sh "rm -rf #{eb_deployer_package}"
  end

  desc "Build package for eb_deployer to deploy to a Ruby environment in tmp directory. It zips all file list by 'git ls-files'"
  task :package => [:clean, :environment] do
    sh "echo ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, access_key_id: '%AWS_ACCESS_KEY_ID%', secret_access_key: '%AWS_SECRET_ACCESS_KEY%' > config/initializers/amazon_ses.rb"
    sh "echo TFF_API_KEY = '%TFF_API_KEY%' > config/initializers/taxifarefinder.rb"
    sh "cp -r ../cplex bin/cplex"
    sh "(find bin/cplex && git ls-files) | zip #{eb_deployer_package} -@"
    sh "rm -r bin/cplex"
    sh "echo TFF_API_KEY = ENV['TFF_API_KEY'] > config/initializers/taxifarefinder.rb"
    sh "echo ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] > config/initializers/amazon_ses.rb"
  end

  desc "Deploy package we built in tmp directory. default to dev environment, specify environment variable EB_DEPLOYER_ENV to override, for example: EB_DEPLOYER_ENV=production rake eb:deploy."
  task :deploy => [:package] do
    app_name = Rails.application.class.parent_name.downcase
    sh "eb_deploy -p #{eb_deployer_package} -e #{eb_deployer_env}"
  end

  desc "Destroy Elastic Beanstalk environments. It won't destroy resources defined in eb_deployer.yml. Default to dev environment, specify EB_DEPLOYER_ENV to override."
  task :destroy do
    sh "eb_deploy -d -e #{eb_deployer_env}"
  end
end
