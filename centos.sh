#!/bin/sh

echo ${1}
ls *.json 2>>error.txt

touch abc.json
ls *.json 2>>error.txt
