#!/bin/bash

writefile=$1
writestr=$2


if [ -z $writefile ] || [ -z $writestr ]
then
	echo "Error: One of the args is missing"
	exit 1
fi

dir=$(dirname $writefile)

if [ ! -d $dir ]
then
	mkdir -p $dir
fi

touch $writefile

if [ $? -gt 0 ]
then
	echo "Error:file cannot be created"
	exit 1
fi

echo $writestr > $writefile 





