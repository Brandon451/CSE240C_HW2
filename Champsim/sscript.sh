#!/bin/bash

result_dir=/Users/brandon/Documents/CoursesWi22/CSE240C/Homework2/ChampSim/results_compile

for exp_dir in $result_dir/*
do
        if [[ -d $exp_dir ]]
	then
		echo Processing $exp_dir/...
        	grep -rnw $exp_dir -e 'CPU 0 cumulative IPC' | awk '{split($1, temp1, "/"); split(temp1[11], temp2, "."); print temp2[1]",", $5}' > $exp_dir/${exp_dir##*/}_ipc.csv
        	sort -k1 -n -t, $exp_dir/${exp_dir##*/}_ipc.csv -o $exp_dir/${exp_dir##*/}_ipc.csv

        	grep -rnw $exp_dir -e 'LLC TOTAL' | awk '{split($1, temp1, "/"); split(temp1[11], temp2, "."); print temp2[1]",", ((($8+0)/100000))}' > $exp_dir/${exp_dir##*/}_mpki.csv
        	sort -k1 -n -t, $exp_dir/${exp_dir##*/}_mpki.csv -o $exp_dir/${exp_dir##*/}_mpki.csv
	fi	
done

num_policy=$(jq '.replacement_policy | length' space_explore.json)
((num_policy=num_policy-1))

for policy_index in $( seq 0 $num_policy)
do
        policy=$(((jq ".replacement_policy[$policy_index] | keys | @sh" space_explore.json) | tr -d \') | tr -d \")
        #echo $policy
	touch $result_dir/$policy\_base_ipc.csv
	touch $result_dir/$policy\_base_mpki.csv

	echo "Traces, LRU, ship, $policy" > $result_dir/$policy\_base_ipc.csv
	echo "Traces, LRU, ship, $policy" > $result_dir/$policy\_base_mpki.csv

	paste $result_dir/champsim_lru_base/champsim_lru_base_ipc.csv $result_dir/champsim_ship_base/champsim_ship_base_ipc.csv $result_dir/champsim_$policy\_base/champsim_$policy\_base_ipc.csv | awk '{print $1, $2",", $4",", $6}' >> $result_dir/$policy\_base_ipc.csv 	
	paste $result_dir/champsim_lru_base/champsim_lru_base_mpki.csv $result_dir/champsim_ship_base/champsim_ship_base_mpki.csv $result_dir/champsim_$policy\_base/champsim_$policy\_base_mpki.csv | awk '{print $1, $2",", $4",", $6}' >> $result_dir/$policy\_base_mpki.csv 	

	param_index=$(jq ".replacement_policy[$policy_index] .$policy | length" space_explore.json)
        ((param_index=param_index-1))
        if [[ $param_index -gt -1 ]]
        then
                for param_index in $( seq 0 $param_index)
                do
                        param=$(((jq ".replacement_policy[$policy_index] .$policy[$param_index] | keys | @sh" space_explore.json) | tr -d \') | tr -d \")
                        #echo $param
			touch $result_dir/$policy\_$param\_ipc.csv
			touch $result_dir/$policy\_$param\_mpki.csv

			param_array_ipc=("$result_dir/champsim_lru_base/champsim_lru_base_ipc.csv" "$result_dir/champsim_ship_base/champsim_ship_base_ipc.csv" "$result_dir/champsim_${policy}_base/champsim_${policy}_base_ipc.csv")
			param_array_mpki=("$result_dir/champsim_lru_base/champsim_lru_base_mpki.csv" "$result_dir/champsim_ship_base/champsim_ship_base_mpki.csv" "$result_dir/champsim_${policy}_base/champsim_${policy}_base_mpki.csv")
			
			param_array_ipc_header=("Traces" "LRU" "ship" "${policy}_base")
			param_array_mpki_header=("Traces" "LRU" "ship" "${policy}_base")

			param_val_index=$(jq ".replacement_policy[$policy_index] .$policy[$param_index] .$param | length" space_explore.json)
                        ((param_val_index=param_val_index-1))
                        if [[ $param_val_index -gt -1 ]]
                        then
                                for param_val_index in $( seq 0 $param_val_index )
                                do
                                        param_val=$(((jq ".replacement_policy[$policy_index] .$policy[$param_index] .$param[$param_val_index] | @sh" space_explore.json) | tr -d \') | tr -d \")
                                        #echo $param_val
					
					if [ -f ${result_dir}/champsim_${policy}_${param}_${param_val}/champsim_${policy}_${param}_${param_val}_ipc.csv ]; then	
						param_array_ipc+=(${result_dir}/champsim_${policy}_${param}_${param_val}/champsim_${policy}_${param}_${param_val}_ipc.csv)
						param_array_ipc_header+=(${policy}_${param}_${param_val})
					fi
					if [ -f ${result_dir}/champsim_${policy}_${param}_${param_val}/champsim_${policy}_${param}_${param_val}_mpki.csv ]; then
						param_array_mpki+=(${result_dir}/champsim_${policy}_${param}_${param_val}/champsim_${policy}_${param}_${param_val}_mpki.csv)
						param_array_mpki_header+=(${policy}_${param}_${param_val})
					fi
				done
			fi
			
			#paste ${param_array[@]} | awk '{print $1, $2",", $4",", $6}' >> $result_dir/$policy\_base_ipc.csv
			
			#paste -d"," ${param_array_ipc[@]} | awk "{for (i = 1; i <= 2; ++i) print ${i}}"
			echo $result_dir/$policy\_$param
			if [[ ${#param_array_ipc[@]} -gt 3 ]]; then
				echo ${param_array_ipc_header[@]} | awk '{split($0, temp, " "); for(i=1; i<=length(temp); i++) printf temp[i]","; printf"\n"}' >  $result_dir/$policy\_$param\_ipc.csv
				#echo "Traces, LRU, ship, $policy" > $result_dir/$policy\_$param\_ipc.csv
				paste -d"," ${param_array_ipc[@]} | awk '{split($0, temp, ","); printf "\n"temp[1] ;for (i=0; i<length(temp); i++) if(i%2 == 0) printf temp[i]","}' | tail -n +2 >> $result_dir/$policy\_$param\_ipc.csv 
			fi
			if [[ ${#param_array_mpki[@]} -gt 3 ]]; then
				echo ${param_array_mpki_header[@]} | awk '{split($0, temp, " "); for(i=1; i<=length(temp); i++) printf temp[i]","; printf"\n"}' >  $result_dir/$policy\_$param\_mpki.csv
				#echo "Traces, LRU, ship, $policy" > $result_dir/$policy\_$param\_mpki.csv
				paste -d"," ${param_array_mpki[@]}| awk '{split($0, temp, ","); printf "\n"temp[1] ;for (i=0; i<length(temp); i++) if(i%2 == 0) printf temp[i]","}' | tail -n +2 >> $result_dir/$policy\_$param\_mpki.csv 
			fi
			#echo ${param_array_ipc[@]}
		done
	fi

done
