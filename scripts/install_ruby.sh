#!/bin/bash -ex

if [ ! -d ~/.rbenv ]; then
    sudo apt-get -y install build-essential libreadline-dev libssl-dev zlib1g-dev git-core
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
    echo 'eval "$(rbenv init -)"' >> ~/.profile
	#change sources to ruby.taobao.org
fi
sed -i 's!ftp.ruby-lang.org/pub/ruby!ruby.taobao.org/mirrors/ruby!'  $(rbenv root)/plugins/ruby-build/share/ruby-build/*
source ~/.profile
if ! (rbenv versions | grep -q 1.9.3-p484 ); then
    rbenv install 1.9.3-p484
fi
rbenv local 1.9.3-p484
gem sources -r http://rubygems.org/
gem sources -r https://ruby.taobao.org
gem sources -a https://ruby.taobao.org

gem install bundler --no-rdoc --no-ri
bundle config mirror.https://rubygems.org https://ruby.taobao.org
bundle config mirror.http://rubygems.org http://ruby.taobao.org
rbenv rehash
