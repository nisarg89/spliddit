#!/bin/bash
echo "HERE in predeploy"
ln -i /var/app/staging/vendor/bundle/ruby/3.2.0/extensions/x86_64-linux/3.2.0/sassc-2.4.0/sassc/libsass.so /var/app/staging/vendor/bundle/ruby/3.2.0/gems/sassc-2.4.0/ext/libsass.so
echo $?
echo "HERE in predeploy 2"
printenv
/bin/su webapp -c "bundle exec /opt/elasticbeanstalk/config/private/checkforraketask.rb assets:precompile"
if [ $? -eq 0 ]
then
  /bin/su webapp -c "bundle exec rake assets:precompile"
else
  echo "LOGLOG checkforraketask failed"
fi
echo "HERE in predeploy 3"
/bin/su webapp -c "bundle exec /opt/elasticbeanstalk/config/private/checkforraketask.rb db:migrate"
if [ $? -eq 0 ]
then
  /bin/su webapp -c "bundle exec rake db:migrate"
else
  echo "LOGLOG checkforraketask failed"
fi
echo "HERE in predeploy 4"
