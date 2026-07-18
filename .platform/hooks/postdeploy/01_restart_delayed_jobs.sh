#!/usr/bin/env bash
cd /var/app/current/ || exit
su -c "chmod +x script/delayed_job"
su webapp -c "RAILS_ENV=production bundle exec rake db:migrate"
su webapp -c "RAILS_ENV=production script/delayed_job --pid-dir=/var/app/containerfiles/pids -n 2 restart"
