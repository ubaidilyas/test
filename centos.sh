#!/bin/sh


ls *.json 2>>error.txt

touch abc.json
ls *.json 2>>error.txt


if [ -s error.txt ]; then
  echo full
  echo $1

else
	echo empty
	echo $1
	rm *.txt
fi
