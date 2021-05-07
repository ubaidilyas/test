#!/bin/sh

# Creating list of JobID and ID of Apps
curl --header "X-Nomad-Token: ${2}" ${3}/v1/allocations | sed 's/,/\n/g' > allocations.txt   
grep '"JobID' allocations.txt | cut -d\" -f4 > jobid.txt 
grep '"ID' allocations.txt  | cut -d\" -f4 > id.txt
paste -d: jobid.txt  id.txt | sort -u -t: -k1,1 > unique_id_job.txt

#Creating list of Clients (for calculating count for type system)
curl --header "X-Nomad-Token: ${2}" ${3}/v1/nodes | sed 's/,/\n/g' >nodes.txt
ccount=`grep '"ID"' nodes.txt | wc -l`
azwe=$ccount
grep '"ID"' nodes.txt | cut -d\" -f4 > id_nodes.txt
while IFS=: read -r id; do
curl --header "X-Nomad-Token: ${2}" ${3}/v1/node/$id  | sed 's/,/\n/g' >> $id.txt
if [ `grep '"dc":"GT-DC3"' $id.txt` ]; then
azwe=$((azwe-1))
fi
rm $id.*
done <id_nodes.txt

#Creating initial file for daily report
echo "Days/Application:Count:CPU:Memory:Size:Business_Support:Techincal_Support" > current.txt

#Calculating cpu,memory,count
while IFS=: read -r jobid id; do
curl --header "X-Nomad-Token: ${2}" ${3}/v1/allocation/$id > $jobid.json
	memory=`cat $jobid.json | sed 's/,/\n/g' |  grep -o '"MemoryMB.*' | grep -o '[0-9]*[0-9]' | sort -nr | head -1`
	count=`cat $jobid.json | sed 's/,/\n/g' | grep -o 'Count.*' |grep -o '[0-9]*[0-9]' | sort -nr | head -1`
	cpu=`cat $jobid.json | sed 's/,/\n/g' | grep -o 'CPU.*' |grep -o '[0-9]*[0-9]' | sort -nr | head -1`
#Calculating size
	if [ $memory -lt 256 ]; then
		size="$memory:S"
	elif [ $memory -lt 1024 ] && [ $memory -gt 256 ]; then
		size="$memory:M"
	else 
		size="$memory:L"
	fi
#Extracting Bussiness and Technical Support
curl --header "X-Consul-Token: ${4}" ${5}/v1/catalog/service/$jobid > $jobid_s.json
bsup=`cat $jobid_s.json | sed 's/\",\"/\n/g' | sed 's/:\[\"/\n/g' | grep -m 1 "business_support="`
tsup=`cat $jobid_s.json | sed 's/\",\"/\n/g' | sed 's/:\[\"/\n/g' | grep -m 1 "technical_support="`

#Assigning count according to type of application	
string=`grep '"Type":"system"' $jobid.json`
if [ -z $string ]; then
echo "$jobid.$1:$count:$cpu:$size:$bsup:$tsup" >> current.txt
else
stringvar1=`grep '"RTarget":"GT-DC3"' $jobid.json`
if [ -n "$stringvar1" ]; then
echo "$jobid.$1:$(((ccount-azwe)*count)):$cpu:$size:$bsup:$tsup" >> current.txt
else
echo "$jobid.$1:$((azwe*count)):$cpu:$size:$bsup:$tsup" >> current.txt
fi
fi
rm $jobid.json
done <unique_id_job.txt

#Creating Daily Report report
month=`date +%m-%Y`
day=`date +%d-%m-%Y`
cat current.txt>>$month.txt
cat current.txt>$day.txt 

#Adding to azure
az storage file upload --source /mnt/resource/workspace/Testing-admin-jobs/cost-reports/$month.txt  -s cost-reports/$1/$month --account-key $secret --account-name mondiaci
az storage file upload --source /mnt/resource/workspace/Testing-admin-jobs/cost-reports/$day.txt   -s cost-reports/$1/$month --account-key $secret --account-name mondiaci
