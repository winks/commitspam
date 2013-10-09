#!/bin/sh

set -e

BASEDIR=/opt/commitspam

EXPECTED_ARGS=4
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
    echo "Usage: `basename $0` {repo_url} {repo_name} {from_email} {to1,to2,to3}"
    exit $E_BADARGS
fi

URL=$1
REPO=$2
FROM=$3
TO=$4

echo $FROM
echo $TO

if [ -d "${BASEDIR}/${REPO}" ]; then
    echo "Directory already exists: ${BASEDIR}/${REPO}"
    exit 1
fi

CONFIG=${BASEDIR}/config_${REPO}.yml

git clone $URL $REPO
cp ${BASEDIR}/_config.yml $CONFIG
sed -i "s/XXX_FROM_XXX/${FROM}/" $CONFIG
sed -i "s/XXX_TO_XXX/${TO}/" $CONFIG
