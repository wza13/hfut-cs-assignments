#!/bin/bash

# put this in build/simplesim-3.0/lab3

opt=(
    "-cache:dl1 dl1:256:32:1:l"
    # change capacity *2 *4 *8 *64
    "-cache:dl1 dl1:512:32:1:l"
    "-cache:dl1 dl1:1024:32:1:l"
    "-cache:dl1 dl1:2048:32:1:l"
    "-cache:dl1 dl1:16384:32:1:l"
    # change association 2 4 8 16 64
    "-cache:dl1 dl1:128:32:2:l"
    "-cache:dl1 dl1:64:32:4:l"
    "-cache:dl1 dl1:32:32:8:l"
    "-cache:dl1 dl1:16:32:16:l"
    "-cache:dl1 dl1:4:32:64:l"
    # change block size *2 *4 *8 *64
    "-cache:dl1 dl1:128:64:1:l"
    "-cache:dl1 dl1:64:128:1:l"
    "-cache:dl1 dl1:32:256:1:l"
    # 2048 is bigger than the block size of l2 cache
    # "-cache:dl1 dl1:4:2048:1:l"
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

rm lab3_95.out
rm temp/lab3_95.out
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
        echo "./../sim-cache ${opt[$j]} -cache:dl2 ul2:1024:256:4:l -cache:il2 dl2 ../benchmark/spec95_little/${exe[$i]}.alpha ${arg[$i]} >> temp/lab3_95.out 2>> lab3_95.out"
        ./../sim-cache ${opt[$j]} -cache:dl2 ul2:1024:256:4:l -cache:il2 dl2 ../benchmark/spec95_little/${exe[$i]}.alpha ${arg[$i]} >> temp/lab3_95.out 2>> lab3_95.out
    done
done
