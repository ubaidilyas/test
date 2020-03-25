#!/bin/sh
curl --header "X-Nomad-Token: 4d67205e-b898-00c6-63ce-6ee324da5a74" http://172.21.38.9:4646/v1/allocations > allocations.txt
tr , '\n' < allocations.txt > 2id.txt   
grep '"JobID' 2id.txt | cut -d\" -f4 > jobid.txt 
grep '"ID' 2id.txt  | cut -d\" -f4 > id.txt
paste -d: jobid.txt id.txt > test_together.txt
sort -u -t: -k1,1 test_together.txt > test_unique_together.txt
curl --header "X-Nomad-Token: 4d67205e-b898-00c6-63ce-6ee324da5a74" http://172.21.38.9:4646/v1/nodes >nodes.json
tr , '\n' <nodes.json > nodes.txt
ccount=`grep '"ID"' nodes.txt | wc -l`
grep '"ID"' nodes.txt | cut -d\" -f4 > test_unique_nodes.txt
while IFS=: read -r id; do
curl --header "X-Nomad-Token: 4d67205e-b898-00c6-63ce-6ee324da5a74" http://172.21.38.9:4646/v1/node/$id > $id.json
tr , '\n' <$id.json > $id.txt
stringvar1=`grep '"dc":"GT-DC3"' $id.txt`
if [ -n stringvar1 ]; then
azwe=$((ccount-1))
fi
rm $id.*
done <test_unique_nodes.txt
rm 2id.txt allocations.txt test_together.txt jobid.txt id.txt nodes.* 
echo "Application:Count:CPU:Memory:Days" > current.txt
while IFS=: read -r jobid id; do
curl --header "X-Nomad-Token: 4d67205e-b898-00c6-63ce-6ee324da5a74" http://172.21.38.9:4646/v1/allocation/$id > $jobid.json
tr , '\n' < $jobid.json > $jobid.txt
string=`grep '"Type":"system"' $jobid.txt`
if [ -z $string ]; then
	memory=`grep '"MemoryMB' $jobid.txt | grep -o '"MemoryMB.*'| cut -d':' -f2 | tr '\n' ' ' | perl -MList::Util=max -lane 'print max(@F)'`
	count=`grep 'Count' $jobid.txt |tr ':' ' ' |perl -MList::Util=max -lane 'print max(@F)'`
	cpu=`grep '"CPU' $jobid.txt | grep -o '"CPU.*'| cut -d':' -f2 | tr '\n' ' ' | perl -MList::Util=max -lane 'print max(@F)'`
	echo "$jobid:$count:$cpu:$memory" >> current.txt
else
		memory=`grep '"MemoryMB' $jobid.txt | grep -o '"MemoryMB.*'| cut -d':' -f2 | tr '\n' ' ' | perl -MList::Util=max -lane 'print max(@F)'`
		count=`grep 'Count' $jobid.txt |tr ':' ' ' |perl -MList::Util=max -lane 'print max(@F)'`
		cpu=`grep '"CPU' $jobid.txt | grep -o '"CPU.*'| cut -d':' -f2 | tr '\n' ' ' | perl -MList::Util=max -lane 'print max(@F)'`
stringvar1=`grep "Constraints" $jobid.txt | grep "meta.dc"`
if [ -z $stringvar1 ]; then
echo "$jobid:$((ccount*count)):$cpu:$memory" >> current.txt
else
echo "$jobid:$((azwe*count)):$cpu:$memory" >> current.txt
fi
fi
rm $jobid.txt $jobid.json
done <test_unique_together.txt

cat current.txt>>`date +%m`.txt
sort -t: -k1,1 `date +%m`.txt | uniq -c | cut -d" " -f7 > days.txt
sort -t: -k1,1 `date +%m`.txt | uniq -c | cut -d" " -f8 > app.txt
paste -d: app.txt days.txt > `date +%d-%m-%Y`.txt


rm test* days* current* app*	