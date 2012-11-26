#!/usr/bin/env bash

# runs a benchmark without additions

# usage:           ./dacapo <benchmark>
# example usage:   ./dacapo avrora
#                  ./dacapo h2

# list of all benchmarks can be found at http://dacapobench.org/benchmarks.html 

# load-time weaving via aspectjweaver 1.6.12
java -Xms256M -Xmx1024M -jar ${DACAPO} $1
