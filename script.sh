#!/bin/bash

trace_dir=/datasets/cs240c-wi22-a00-public/data/Assignment2

batch=8

for build in bin/*; do
	for trace in $trace_dir/*B.trace.xz; do
		echo
		echo Running trace ${build##*/}\_${trace##*/}
		sim_complete=$(grep -nw results/${build##*/}/${trace##*/}.txt -e 'complete' | wc -l)
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
