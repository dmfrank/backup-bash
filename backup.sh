#!/bin/bash

## vars
PREFIX=`date +%FT%T`
CONFIG_DIR=./conf/
CONFIG=$CONFIG_DIR/config
TARGET=$CONFIG_DIR/options

# read backup target options congiguration file
. $TARGET 

function backmeup {
	for f in $(find $TARGET_BKP_DIRNAME -name '*'); 
		do grep -q -F $f $CONFIG_DIR/toc || echo $f > $CONFIG_DIR/toc; 
	done
}

function read_option {
	cat $CONFIG | while IFS='' read -r line; 
	do 
		[[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]] && continue
		for o in $line
		do
			if [[ $o == *M ]] || [[ $o == *G ]] || [[  $o == *k ]] || [[ $o == *c ]]
			then
				litera='${o: -1}'
				size='${o: 1: -2}'
			fi
		done
	done
}

read_option
echo $litera
