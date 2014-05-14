#!/bin/sh

set -e

BASEDIR=/opt/commitspam

EXPECTED_ARGS=5
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
    echo "Usage: `basename $0` {repo} {before commit ID} {after commit ID} {ref} {notifier}"
    exit $E_BADARGS
fi

REPO=$1
BEFORE=$2
AFTER=$3
REF=$4
NOTIFIER=$5

if [ ! -d "${BASEDIR}/${REPO}" ]; then
    echo "Not a directory: ${BASEDIR}/${REPO}"
    exit 1
fi

CONFIG=${BASEDIR}/config_${REPO}.yml

# Assume repository exists in directory and user has pull access
cd ${BASEDIR}/$REPO
git pull --rebase
echo $BEFORE $AFTER $REF | $NOTIFIER $CONFIG

exit $?
