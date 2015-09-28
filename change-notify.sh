#!/bin/sh

set -e

DATADIR=/opt/commitspam/data

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

if [ ! -d "${DATADIR}/${REPO}" ]; then
    echo "Not a directory: ${DATADIR}/${REPO}"
    exit 1
fi

CONFIG=${DATADIR}/config_${REPO}.yml

if [ "refs/heads/master" = "$REF" ]; then

       # Assume repository exists in directory and user has pull access
       cd ${DATADIR}/$REPO
       git pull
       echo $BEFORE $AFTER $REF | $NOTIFIER $CONFIG

fi

exit $?
