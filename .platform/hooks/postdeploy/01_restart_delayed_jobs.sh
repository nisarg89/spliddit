#!/usr/bin/env bash
#. /opt/elasticbeanstalk/support/envvars
#cd $EB_CONFIG_APP_CURRENT
#su -c "chmod +x script/delayed_job"
#su -c "bundle exec rake db:init_data" $EB_CONFIG_APP_USER
#su -c "bundle exec rake db:migrate" $EB_CONFIG_APP_USER
#su -c "RAILS_ENV=production script/delayed_job --pid-dir=$EB_CONFIG_APP_SUPPORT/pids -n 2 restart" $EB_CONFIG_APP_USER
