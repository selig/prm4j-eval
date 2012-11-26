#!/usr/bin/env bash

# runs a benchmark without additions

# usage:           sh runBenchmark.sh <benchmark>
# example usage:   sh runBenchmark.sh avrora
#                  sh runBenchmark.sh h2

# list of all benchmarks can be found at http://dacapobench.org/benchmarks.html 

# load-time weaving via aspectjweaver 1.6.12
java -Xms256M -Xmx1024M -jar lib/dacapo-9.12-bach.jar $1
