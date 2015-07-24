#!/bin/bash -ex

#获取内网的ip
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | grep 10.`}

./scripts/generate_deploy_manifest.sh

(
    cd nise_bosh
	bundle config mirror.https://rubygems.org https://ruby.taobao.org
	bundle config mirror.http://rubygems.org http://ruby.taobao.org
    bundle install

    # Old spec format
    sudo env PATH=$PATH bundle exec ./bin/nise-bosh -y ../cf-release ../manifests/deploy.yml micro -n ${NISE_IP_ADDRESS}
    # New spec format, keeping the  monit files installed in the previous run
    sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y ../cf-release ../manifests/deploy.yml micro_ng -n ${NISE_IP_ADDRESS}
)
