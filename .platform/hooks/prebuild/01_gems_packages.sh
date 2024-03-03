#!/usr/bin/env bash
echo "HERE in prebuild"
sudo yum install -y python3 python3-pip
/usr/bin/bundle config build.nokogiri --use-system-libraries
bundle config --local build.sassc --disable-march-tune-native
