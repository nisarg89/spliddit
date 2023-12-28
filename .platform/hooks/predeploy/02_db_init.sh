#!/usr/bin/env bash
. /opt/elasticbeanstalk/containerfiles/envvars
cd $EB_CONFIG_APP_ONDECK
su -c "leader_only /usr/local/bin/rake db:init_data" $EB_CONFIG_APP_USER ||
echo "Rake task failed to run, skipping init_data."
true
