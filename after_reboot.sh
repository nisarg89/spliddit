#!/bin/sh
sudo passwd -d root
sudo passwd -d webapp
su -c "sh /opt/elasticbeanstalk/hooks/appdeploy/post/99_restart_delayed_job.sh" webapp