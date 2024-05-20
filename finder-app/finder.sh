#!/bin/bash

filesdir=$1
searchstr=$2

if [ -z "$filesdir" ] || [ -z "$searchstr" ]
then 
	echo "Error: one of the parameters is missing"
	exit 1
elif [ ! -d "$filesdir" ]
then
	echo "Error: file path is wrong"
	exit 1
fi

noOfFiles=$( ls $filesdir | wc -l )

if [ $noOfFiles -gt 0 ]
then
	noOfMatchingLines=$( grep -r $searchstr $filesdir | wc -l)
else
	noOfMatchingLines=0
fi

echo "The number of files are $noOfFiles and the number of matching lines are $noOfMatchingLines"
