#!/bin/bash -ex

#获取内网的ip
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global eth0' | cut -f 6 -d ' ' | cut -f1 -d '/'`}

sed "s/192.168.10.10/${NISE_IP_ADDRESS}/g" manifests/template.yml > manifests/deploy.yml

DB_IP=$(grep  "^ *DB_IP" scripts/cf.conf |awk -F "=" '$1{print $2}')
if [ "${DB_IP}" != "" ]; then
    sed -i "s/DB_IP/${DB_IP}/g" manifests/deploy.yml
fi

ELK_IP=$(grep  "^ *ELK_IP" scripts/cf.conf |awk -F "=" '$1{print $2}')
if [ "${ELK_IP}" != "" ]; then
    sed -i "s/ELK_IP/${ELK_IP}/g" manifests/deploy.yml
fi

NISE_DOMAIN=$(grep  "^ *DOMAIN" scripts/cf.conf |awk -F "=" '$1{print $2}')
if [ "${NISE_DOMAIN}" != "" ]; then
    if (! sed --version 1>/dev/null 2>&1); then
        # not a GNU sed
        sed -i '' "s/${NISE_IP_ADDRESS}.xip.io/${NISE_DOMAIN}/g" manifests/deploy.yml
    else
        sed -i "s/${NISE_IP_ADDRESS}.xip.io/${NISE_DOMAIN}/g" manifests/deploy.yml
    fi
fi

NISE_PASSWORD=$(grep  "^ *PASSWD" scripts/cf.conf |awk -F "=" '$1{print $2}')
if [ "${NISE_PASSWORD}" != "" ]; then
    if (! sed --version 1>/dev/null 2>&1); then
        # not a GNU sed
        sed -i '' "s/c1oudc0w/${NISE_PASSWORD}/g" manifests/deploy.yml
    else
        sed -i "s/c1oudc0w/${NISE_PASSWORD}/g" manifests/deploy.yml
    fi
fi
