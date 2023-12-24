#!/bin/bash
echo "HERE in predeploy"
ln -i /var/app/staging/vendor/bundle/ruby/3.2.0/extensions/x86_64-linux/3.2.0/sassc-2.4.0/sassc/libsass.so /var/app/staging/vendor/bundle/ruby/3.2.0/gems/sassc-2.4.0/ext/libsass.so
