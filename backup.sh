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
					local litera="${o: ${#o} - 1}"
					local signSz="${o: 1: ${#o} - 3}"
					local prefix="${o: 1: 1}"
					local numSz="${signSz: 2: ${#signSz} - 3}"
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
			((cnt++))
		done
		# loop over target directory
		#IFS=$'\n'; set -f
		
		for f in $(find $dir -name "$filemask"); do	
			# cut current dir symbol
			local filepath="${f: 1}"
			# fetching filesize 
			fsize=$(wc -c < "$f")
			#echo $fsize
			# verify on existing dir in $BKP_DIR
			if [[ ! -d "$(dirname "$BKP_DIR$filepath")" ]]; then
				mkdir -p "$(dirname "$BKP_DIR$filepath")"
			fi

			# verify on existing file in $BKP_DIR
			if [[ ! -f "$BKP_DIR$filepath" ]]; then
				cp "$f" "$BKP_DIR$filepath"
			fi

			local matched=false
		
			#echo $prefix
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
				HUNKS=$(diff "$f" "$BKP_DIR$filepath") 
				if [ "$HUNKS" != "" ]; then
					echo $HUNKS > "$BKP_DIR$filepath".$(date +%s).patch
				fi
			fi
		done
		#unset IFS; set +f
	done
	echo "#### Done ####"
}

while true; do
	# tick for execution
	sleep 2
	run
done
