#!/bin/sh


az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
az storage file upload --source /mnt/resource/workspace/Testing-admin-jobs/cost-reports/test_ubaid.txt  -s cost-reports/test --account-key $secret --account-name mondiaci
az storage file download -s cost-reports -p test/test_ubaid.txt --dest /mnt/resource/workspace/Testing-admin-jobs/cost-reports/download --account-key $secret --account-name mondiaci
string=`az storage file exists -s cost-reports -p test/test_ubaid.txt --account-key $secret --account-name mondiaci | grep -o true`
echo $string
if [ $string=true ]; then
		echo " file exists"
	else 
		echo "file does not exist"
	fi
string=`az storage file exists -s cost-reports -p test/test_ubaid1.txt --account-key $secret --account-name mondiaci | grep -o true`
echo $string
if [ $string=true ]; then
		echo " file exists"
	else 
		echo "file does not exist"
	fi