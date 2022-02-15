#!/bin/bash

#trace_dir=/datasets/cs240c-wi22-a00-public/data/Assignment2
trace_dir=/Users/brandon/Documents/CoursesWi22/CSE240C/Homework2/traces

batch=8

for build in bin/*; do
	for trace in $trace_dir/*B.trace.xz; do
		echo Running trace ${build##*/}\_${trace##*/}
		if [ ! -d "results/${build##*/}" ]
		then
			#echo results/${build##*/}
			mkdir results/${build##*/}
		fi	
		
		sim_complete=$(grep -nw results/${build##*/}/${trace##*/}.txt -e 'ChampSim completed all CPUs' | wc -l)
		if [[ $sim_complete -eq 0 ]]
		then
			$build --warmup_instructions 10000000 --simulation_instructions 100000000 $trace > results/${build##*/}/${trace##*/}.txt &
		else
			echo Run already completed for this trace for the bin file, skipping...
		fi
		num_jobs=( $(jobs -p | wc -l) )
		if [[ $num_jobs -ge $batch ]]
		then
			echo Reached max, waiting
			wait -n
		fi
	done
done

trap 'pkill -P $$' SIGINT SIGTERM
