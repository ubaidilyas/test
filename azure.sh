#!/bin/sh


az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
string=`az storage directory exists -s cost-reports -n \`date +%m-%Y\` --account-key $secret --account-name mondiaci | grep -o true`
echo $string
if [ -z $string ]; then
		az storage directory create -s cost-reports -n \`date +%m-%Y\`
		./fnlfinal.sh
	else 
		az storage file download -s cost-reports -p \`date +%m-%Y\`/\`date +%m-%Y\`.txt --dest /mnt/resource/workspace/Testing-admin-jobs/cost-reports --account-key $secret --account-name mondiaci
		./fnlfinal.sh
	fi