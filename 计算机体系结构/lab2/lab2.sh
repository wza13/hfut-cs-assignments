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
    "164.gzip/gzip00.peak.ev6"
    "175.vpr/vpr00.peak.ev6"
    "181.mcf/mcf00.peak.ev6"
    "256.bzip2/bzip200.peak.ev6"
)

arg=(
    "../benchmark/CINT2000/164.gzip/data/ref/input/input.source 60"
    "../benchmark/CINT2000/175.vpr/data/ref/input/net.in ../benchmark/CINT2000/175.vpr/data/ref/input/arch.in temp/place.out temp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2"
    "../benchmark/CINT2000/181.mcf/data/ref/input/inp.in"
    "../benchmark/CINT2000/256.bzip2/data/ref/input/input.source 58"
)

rm lab2.out

for (( i = 0 ; i < ${#exe[@]} ; i++ ))
do
    for (( j = 0 ; j < ${#opt[@]} ; j++ ))
    do
        echo "./../sim-bpred -bpred${opt[$j]} ../benchmark/spec95_little/${exe[$i]}.alpha ${arg[$i]} >> temp/lab2_95.out 2>> lab2_95.out"
        ./../sim-bpred -bpred${opt[$j]} ../benchmark/CINT2000/${exe[$i]} ${arg[$i]} 2>> lab2.out
    done
done
