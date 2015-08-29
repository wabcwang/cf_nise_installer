#!/bin/bash -ex

path=`dirname $0`
cd "$path"/../

sudo /var/vcap/bosh/bin/monit
sleep 5

if [ "" != "$( find /var/vcap/jobs -name postgres)" ]; then
    sudo /var/vcap/bosh/bin/monit start postgres
    sleep 20
fi

if [ "" != "$( find /var/vcap/jobs -name nats)" ]; then
    sudo /var/vcap/bosh/bin/monit start nats
    sleep 20
fi

if [ "" != "$( find /var/vcap/jobs -name nfs_mounter)" ]; then
    sudo /var/vcap/bosh/bin/monit start nfs_mounter
    sleep 20
fi

sudo /var/vcap/bosh/bin/monit start all

echo "Waiting for all processes to start"
for ((i=0; i < 120; i++)); do
    if ! (sudo /var/vcap/bosh/bin/monit summary | tail -n +3 | grep -v -E "(running|accessible)$"); then
        break
    fi
    sleep 10
done

if (sudo /var/vcap/bosh/bin/monit summary | tail -n +3 | grep -v -E "(running|accessible)$"); then
    echo "Found process failed to start"
    exit 1
fi

set +x
echo "All processes have been started!"
api_url=`grep srv_api_uri: ./manifests/deploy.yml | awk '{ print $2 }'`
password=`grep ' - admin' ./manifests/deploy.yml | cut -f 2 -d '|'  `
echo "Login : 'cf login -a ${api_url} -u admin -p ${password} --skip-ssl-validation'"
echo "Download CF CLI from https://github.com/cloudfoundry/cli"
