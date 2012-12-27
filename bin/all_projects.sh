#!/bin/bash

usage()
{
  echo ""
	echo "Usage: $0 [-p num_processes] [-d output_dir] file"
  echo "Runs pull_req_data_extraction for an input file using multiple processes"
  echo "Options:"
  echo "  -p Number of processes to run in parallel (default: 1)"
  echo "  -d Output directory (default: .)"
	exit 1
}

parallel=1
dir='.'

while getopts "p:d:" o
do
	case $o in
	p) 	
    parallel=$OPTARG ; 
    echo "Using $parallel processes"; 
    ;;
  d) 	
    dir=$OPTARG ; 
    echo "Using $dir for output"; 
    ;;
	\?) 
    echo "Invalid option: -$OPTARG" >&2 ; 
    usage 
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
	esac
done

# Process remaining arguments after getopts as per:
# http://stackoverflow.com/questions/11742996/shell-script-is-mixing-getopts-with-positional-parameters-possible
if [ -z ${@:$OPTIND:1} ]; then
  usage
else
  input=${@:$OPTIND:1}
fi

cat $input |
grep -v "^#"|
while read pr; do 
  name=`echo $pr|cut -f2 -d' '`
  
  echo "(ruby -Ibin bin/pull_req_data_extraction.rb -c config.yaml $pr |grep -v '^[DUG]') 1>$dir/$name.csv 2>$dir/$name.err"
done | xargs -P $parallel -Istr bash -c str
