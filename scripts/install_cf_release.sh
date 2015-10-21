#!/bin/bash -ex

#获取内网的
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global eth0' | cut -f 6 -d ' ' | cut -f1 -d '/'`}

./scripts/generate_deploy_manifest.sh

(
	cd nise_bosh
	bundle install
        
	if [ "cf.conf" != "$( sudo ls /root/shell/ | grep cf.conf)" ];then
		JOB=$(grep  "^ *JOB" ../scripts/cf.conf |awk -F "=" '$1{print $2}')
                INDEX=$(grep  "^ *INDEX" ../scripts/cf.conf |awk -F "=" '$1{print $2}')
	else
        	JOB=$(sudo grep  ":${NISE_IP_ADDRESS}$" /root/shell/cf.conf |awk -F ":" '$1{print $1}')
                INDEX=$(sudo grep  ":${NISE_IP_ADDRESS}$" /root/shell/cf.conf |awk -F ":" '$1{print $2}')
        fi
        
        PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
	sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y ../cf-release ../manifests/deploy.yml metron_agent -n ${NISE_IP_ADDRESS}
        for NAME in ${JOB[@]}
	do
	    if [ "db" = "$NAME" ]; then
	    	# Old spec format
	    	# 编译数据库
            	sudo env PATH=$PATH bundle exec ./bin/nise-bosh -y ../cf-release ../manifests/deploy.yml db -n ${NISE_IP_ADDRESS}
	   else
		# New spec format, keeping the  monit files installed in the previous run
	        # 按需编译各个组件
		sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y -i ${INDEX} ../cf-release ../manifests/deploy.yml ${NAME} -n ${NISE_IP_ADDRESS}
	    fi
	done
)
