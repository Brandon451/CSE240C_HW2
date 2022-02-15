#!/bin/bash

batch=2

trap 'pkill -P $$' SIGINT SIGTERM
for i in {1..10};
do
	sleep $(($i*10)) &
	num_jobs_tr=( $(jobs -p | wc -l) )
	if [[ $num_jobs_tr -ge $batch ]]
 	then
 		echo Reached max, waiting
 		wait -n
	fi
done

wait
