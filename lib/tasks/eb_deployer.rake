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
    # AWS do
    sh "source ~/.bashrc && sed -i '' \"s|ENV\\\['AWS_SECRET_ACCESS_KEY'\\\]|'$AWS_SECRET_ACCESS_KEY'|g\" config/environments/production.rb"
  end

  desc "Build package for eb_deployer to deploy to a Ruby environment in tmp directory. It zips all file list by 'git ls-files'"
  task :package => [:clean, :environment] do
    # Mailer do
    sh "source ~/.bashrc && echo \"ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, access_key_id: \'$AWS_ACCESS_KEY_ID\', secret_access_key: \'$AWS_SECRET_ACCESS_KEY\', signature_version: 4\" > config/initializers/amazon_ses.rb"
    # TFF do
    sh "source ~/.bashrc && echo \"TFF_API_KEY = \'$TFF_API_KEY\'\" > config/initializers/taxifarefinder.rb"
    # Gurobi do
    sh "cp ~/gurobi/aws-gurobi.lic config/gurobi.lic"
    # DATABASE.YML do
    sh "source ~/.bashrc && sed -i '' \"s|ENV\\\['DATABASE_NAME'\\\]|'$DATABASE_NAME'|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|ENV\\\['DATABASE_HOST'\\\]|'$DATABASE_HOST'|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|ENV\\\['DATABASE_PORT'\\\]|'$DATABASE_PORT'|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|ENV\\\['DATABASE_USERNAME'\\\]|'$DATABASE_USERNAME'|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|ENV\\\['DATABASE_PASSWORD'\\\]|'$DATABASE_PASSWORD'|g\" config/database.yml"
    # Package
    sh "(find config/gurobi.lic && git ls-files) | zip #{eb_deployer_package} Gemfile.lock -@"
    # AWS undo
    sh "source ~/.bashrc && sed -i '' \"s|'$AWS_SECRET_ACCESS_KEY'|ENV\\\['AWS_SECRET_ACCESS_KEY'\\\]|g\" config/environments/production.rb"
    # Mailer undo
    sh "echo \"ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, access_key_id: ENV[\'AWS_ACCESS_KEY_ID\'], secret_access_key: ENV[\'AWS_SECRET_ACCESS_KEY\'], signature_version: 4\" > config/initializers/amazon_ses.rb"
    # TFF undo
    sh "echo \"TFF_API_KEY = ENV[\'TFF_API_KEY\']\" > config/initializers/taxifarefinder.rb"
    # Gurobi undo
    sh "rm config/gurobi.lic"
    # database.yml undo
    sh "source ~/.bashrc && sed -i '' \"s|'$DATABASE_NAME'|ENV\\\['DATABASE_NAME'\\\]|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|'$DATABASE_HOST'|ENV\\\['DATABASE_HOST'\\\]|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|'$DATABASE_PORT'|ENV\\\['DATABASE_PORT'\\\]|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|'$DATABASE_USERNAME'|ENV\\\['DATABASE_USERNAME'\\\]|g\" config/database.yml"
    sh "source ~/.bashrc && sed -i '' \"s|'$DATABASE_PASSWORD'|ENV\\\['DATABASE_PASSWORD'\\\]|g\" config/database.yml"
  end

  desc "Deploy package we built in tmp directory. default to dev environment, specify environment variable EB_DEPLOYER_ENV to override, for example: EB_DEPLOYER_ENV=production rake eb:deploy."
  task :deploy => [:package] do
    app_name = Rails.application.class.module_parent_name.downcase
    sh "EB_CLI_DEBUG=1 eb_deploy -p #{eb_deployer_package} -e #{eb_deployer_env}"
  end

  desc "Destroy Elastic Beanstalk environments. It won't destroy resources defined in eb_deployer.yml. Default to dev environment, specify EB_DEPLOYER_ENV to override."
  task :destroy do
    sh "AWS_SDK_LOG_LEVEL=debug eb_deploy -d -e #{eb_deployer_env}"
  end
end
