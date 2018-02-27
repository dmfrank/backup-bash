#!/bin/bash

PREFIX=`date +%FT%T`
BASE_DIR=.
CONFIG=$BASE_DIR/config
BKP_DIR=$BASE_DIR/bkp

function run {
	# verify backup directory existing
	if [ ! -d "$BKP_DIR" ]; then
		# goto backup directory
		mkdir -p $BKP_DIR
	fi
	cat $CONFIG | while IFS='' read -r line; do 
		# Check whether satisfy line to pattern or not
		# skip commented lines
		[[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]] && continue
		local cnt=0
		for o in $line;	do
			# fetch size options
			if [[ $cnt == 0 ]]; then 
				if [[ $o =~ ^\[\+|\-|=&&[0-9]\] ]]; then
					local litera="${o: -1}"
					local signSz="${o: 1: -2}"
					local prefix="${signSz: 0: 1}"
					local numSz="${signSz: 1}"
					local pattern="${o}"
				fi
			fi
			# fetch file mask
			if [[ $cnt == 1 ]]; then
				local filemask="${o}"
			fi
			# fetch target
			if [[ $cnt == 2 ]]; then
				local dir="${o}"
			fi
			
			# loop over target directory
			#IFS=$'\n'; set -f
			
			for f in $(find $dir -name "$filemask"); do	
				# cut current dir symbol
				local filepath="${f: 1}"
				# fetching filesize 
				fsize=$(stat -c%s "$f")
			
				# verify on existing dir in $BKP_DIR
				if [[ ! -d "$(dirname "$BKP_DIR$filepath")" ]]; then
					mkdir -p "$(dirname "$BKP_DIR$filepath")"
				fi

				# verify on existing file in $BKP_DIR
				if [[ ! -d "$BKP_DIR$filepath" ]]; then
					echo "$BKP_DIR$filepath"
				#	touch "$BKP_DIR$filepath"
				fi

				local matched=false
			
				case $prefix in
					-)
						if [[ "$fsize" -lt "$numSz" ]]; then
							matched=true							
						fi
						;;
					+)
						if [[ "$fsize" -gt "$numSz" ]]; then
							matched=true						
						fi
						;;
					=)
						if [[ "$fsize" -eq "$numSz" ]]; then
							matched=true
						fi
						;;
				esac

				if [[ "$matched" = true ]]; then
					#diff "$f" "$BKP_DIR$filepath" > "$BKP_DIR$filepath".$(date +%s).patch
					echo 0
				fi







				

			done
			#unset IFS; set +f





			((cnt++))
		done
	done
	echo "#### Done ####"
}

while true; do
	# tick for execution
	sleep 2
	run
done
