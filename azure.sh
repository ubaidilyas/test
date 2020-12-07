#!/bin/sh


az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
directory=`date +%m-%Y`
string=`az storage directory exists -s cost-reports -n ${1}/$directory --account-key $secret --account-name mondiaci | grep -o true`
echo $string
if [ -z $string ]; then
		az storage directory create -s cost-reports -n ${1}/$directory --account-key $secret --account-name mondiaci
		./fnlfinal.sh ${1} ${2} ${3} ${4} ${5}
	else 
		az storage file download -s cost-reports -p ${1}/$directory/$directory.txt --dest /mnt/resource/workspace/Testing-admin-jobs/cost-reports --account-key $secret --account-name mondiaci
		./fnlfinal.sh ${1} ${2} ${3} ${4} ${5}
	fi
