#!/bin/bash

# put this in build/simplesim-3.0/lab2

opt=(
    " taken"
    " nottaken"
    ":bimod 512"
    ":bimod 1024"
    ":2lev 1 1024 8 0"
    ":2lev 1 64 6 1"
)

exe=(
    "cc1"
    "compress95"
    "go"
    "perl"
)

arg=(
    "-O ../benchmark/spec95_little/1stmt.i"
    "< ../benchmark/spec95_little/input.log"
    "50 9 ../benchmark/spec95_little/2stone9.in"
    "../benchmark/spec95_little/perl-tests.pl"
)

rm lab2_95.out
rm temp/lab2_95.out
cp ../benchmark/spec95_little/input.log.bak ../benchmark/spec95_little/input.log

for (( i = 0 ; i < ${#exe[@]} ; i++ ))
do
    for (( j = 0 ; j < ${#opt[@]} ; j++ ))
    do
        # out of no reason compress95 will delete input.log after using it when run this command in shell script
        if [ -f ../benchmark/spec95_little/input.log.Z ]; then
            rm ../benchmark/spec95_little/input.log.Z
            cp ../benchmark/spec95_little/input.log.bak ../benchmark/spec95_little/input.log
        fi
        echo "./../sim-bpred -bpred${opt[$j]} ../benchmark/spec95_little/${exe[$i]}.alpha ${arg[$i]} >> temp/lab2_95.out 2>> lab2_95.out"
        ./../sim-bpred -bpred${opt[$j]} ../benchmark/spec95_little/${exe[$i]}.alpha ${arg[$i]} >> temp/lab2_95.out 2>> lab2_95.out
    done
done
