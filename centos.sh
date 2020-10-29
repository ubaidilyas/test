#!/bin/sh


ls *.json 2>>error.txt

touch abc.json
ls *.json 2>>error.txt


if [ -s error.txt ]; then
  echo full

else
	echo empty
	rm *.txt
fi
