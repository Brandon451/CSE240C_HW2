#!/bin/bash


policy_index=0

num_policy=$(jq '.replacement_policy | length' space_explore.json)
((num_policy=num_policy-1))

for policy_index in $( seq 0 $num_policy)
do
	policy=$(((jq ".replacement_policy[$policy_index] | keys | @sh" space_explore.json) | tr -d \') | tr -d \")
	echo $policy
	param_index=$(jq ".replacement_policy[$policy_index] .$policy | length" space_explore.json)
	((param_index=param_index-1))
	if [[ $param_index -gt 0 ]]
	then
		for param_index in $( seq 0 $param_index)
		do	
			param=$(((jq ".replacement_policy[$policy_index] .$policy[$param_index] | keys | @sh" space_explore.json) | tr -d \') | tr -d \")
			echo $param
			param_val_index=$(jq ".replacement_policy[$policy_index] .$policy[$param_index] .$param | length" space_explore.json)
			((param_val_index=param_val_index-1))
			if [[ $param_val_index -gt 0 ]]
			then
				for param_val_index in $( seq 0 $param_val_index )
				do
					param_val=$(((jq ".replacement_policy[$policy_index] .$policy[$param_index] .$param[$param_val_index] | @sh" space_explore.json) | tr -d \') | tr -d \")
					echo $param_val
					restore_line=$(grep "#define\ $param.*" ./replacement/$policy/$policy.cc)
					echo $restore_line
					
					#For MacOS
					sed -i "" "s/#define\ $param.*/#define\ $param\ $param_val/g" ./replacement/$policy/$policy.cc
					
					#For linux
					#sed -i "s/#define\ $param.*/#define\ $param\ $param_val/g" ./replacement/$policy/$policy.cc
					tmp=$(mktemp)
					jq ".executable_name = \"bin_to_do/champsim_${policy}_${param}_${param_val}\"" champsim_config.json > "$tmp" && mv "$tmp" champsim_config.json 	
					jq ".LLC .replacement = \"$policy\"" champsim_config.json > "$tmp" && mv "$tmp" champsim_config.json
					./config.sh champsim_config.json
					make
					
					#echo Waiting
					#while [ true ] 
					#do
					#	read -t 3 -n 1
					#	if [ $? = 0 ] 
					#	then
					#		break
					#	else
					#		echo Waiting for keypress
					#	fi
					#done

					#For MacOS	
					sed -i "" "s/#define\ $param.*/$restore_line/g" ./replacement/$policy/$policy.cc
					
					#For linux
					#sed -i "s/#define\ $param.*/$restore_line/g" ./replacement/$policy/$policy.cc
					#echo Waiting
					#while [ true ] 
					#do
					#	read -t 3 -n 1
					#	if [ $? = 0 ] 
					#	then
					#		break
					#	else
					#		echo Waiting for keypress
					#	fi
					#done	
				done
			fi
		done
	fi
done

