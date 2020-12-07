#!/bin/sh




# Creating list of JobID and ID of Apps
curl --header "X-Nomad-Token: ${2}" ${3}/v1/allocations > test_allocations.txt
tr , '\n' < test_allocations.txt > test_2id.txt   
grep '"JobID' test_2id.txt | cut -d\" -f4 > test_jobid.txt 
grep '"ID' test_2id.txt  | cut -d\" -f4 > test_id.txt
paste -d: test_jobid.txt test_id.txt > test_together.txt
sort -u -t: -k1,1 test_together.txt > test_unique_together.txt

#Creating list of Clients (for calculating count for type system)
curl --header "X-Nomad-Token: ${2}" ${3}/v1/nodes >test_nodes.json
tr , '\n' <test_nodes.json > test_nodes.txt
ccount=`grep '"ID"' test_nodes.txt | wc -l`
azwe=$ccount
grep '"ID"' test_nodes.txt | cut -d\" -f4 > test_unique_nodes.txt
while IFS=: read -r id; do
curl --header "X-Nomad-Token: ${2}" ${3}/v1/node/$id > $id.json
tr , '\n' <$id.json > $id.txt
if [ `grep '"dc":"GT-DC3"' $id.txt` ]; then
azwe=$((azwe-1))
fi
rm $id.*
done <test_unique_nodes.txt

#Creating initial file for daily report
echo "Days/Application:Count:CPU:Memory:Size:Business_Support:Techincal_Support" > test_current.txt

#Calculating cpu,memory,count and size
while IFS=: read -r jobid id; do
curl --header "X-Nomad-Token: ${2}" ${3}/v1/allocation/$id > $jobid.json
tr , '\n' < $jobid.json > $jobid.txt
	memory=`grep '"MemoryMB' $jobid.txt | grep -o '"MemoryMB.*'| cut -d':' -f2 | tr '\n' ' ' | perl -MList::Util=max -lane 'print max(@F)'`
	count=`grep 'Count' $jobid.txt |tr ':' ' ' |perl -MList::Util=max -lane 'print max(@F)'`
	if (( `echo "$count" | wc -l` > 1 ));then
	count=`echo "$count" | wc -l | perl -MList::Util=max -lane 'print max(@F)'`
	fi
	cpu=`grep '"CPU' $jobid.txt | grep -o '"CPU.*'| cut -d':' -f2 | tr '\n' ' ' | perl -MList::Util=max -lane 'print max(@F)'`
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
string=`grep '"Type":"system"' $jobid.txt`
if [ -z $string ]; then
echo "$jobid.$1:$count:$cpu:$size:$bsup:$tsup" >> test_current.txt
else
stringvar1=`grep '"RTarget":"GT-DC3"' $jobid.txt`
if [ -n "$stringvar1" ]; then
echo "$jobid.$1:$(((ccount-azwe)*count)):$cpu:$size:$bsup:$tsup" >> test_current.txt
else
echo "$jobid.$1:$((azwe*count)):$cpu:$size:$bsup:$tsup" >> test_current.txt
fi
fi
rm $jobid.txt $jobid.json
done <test_unique_together.txt

#Creating Daily Report report
month=`date +%m-%Y`
day=`date +%d-%m-%Y`
cat test_current.txt>>$month.txt
cat test_current.txt>$day.txt 

#Removing Unrequired files
rm test*

#Adding to azure
#az storage file upload --source /mnt/resource/workspace/Testing-admin-jobs/cost-reports/$month.txt  -s cost-reports/$1/$month --account-key $secret --account-name mondiaci
#az storage file upload --source /mnt/resource/workspace/Testing-admin-jobs/cost-reports/$day.txt   -s cost-reports/$1/$month --account-key $secret --account-name mondiaci
