#!/bin/bash

for i in ./L3_L4_counts/*
do
    index=$(echo $i | awk 'BEGIN{FS="/"}{print $3}' | grep ".*[0-9][0-9]" -o)
    replace_name=$(cat rnaseq_mapping_list.txt | awk 'BEGIN{FS=" "} NR>1 {print $2}'| grep "7A_${index}")
    echo $replace_name
    mv $i ./L3_L4_counts/$replace_name
done