#!/bin/bash -ex

#获取内网的ip
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | grep 10.`}

./scripts/generate_deploy_manifest.sh

(
    cd nise_bosh
	bundle config mirror.https://rubygems.org https://ruby.taobao.org
	bundle config mirror.http://rubygems.org http://ruby.taobao.org
    bundle install

	JOB=$(grep  "^ *JOB" cf.conf |awk -F "=" '$1{print $2}')
	for NAME in ${JOB[@]}
	do
	    if [ "db"="$NAME" ]; then
		    # Old spec format
			# 编译数据库
            sudo env PATH=$PATH bundle exec ./bin/nise-bosh -y ../cf-release ../manifests/deploy.yml db -n ${NISE_IP_ADDRESS}
		else
			# New spec format, keeping the  monit files installed in the previous run
	        # 按需编译各个组件
		    sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y ../cf-release ../manifests/deploy.yml ${NAME} -n ${NISE_IP_ADDRESS}
	    fi
	done
)
