#!/usr/bin/env bash

# usage:         sh evalMOP <monitored property> <benchmark>

# example usage: sh evalMOP.sh SafeMapIterator avrora
#                sh evalMOP.sh SafeMapIterator h2
#                sh evalMOP.sh SafeIterator eclipse

# list of all monitored properties can be found in lib/mop; each jar is property
# list of all benchmarks can be found at http://dacapobench.org/benchmarks.html 

sh makejars.sh # repackages the properties, in case the implementation has changed (packages classes, so Eclipse has to have build them already)

# load-time weaving via aspectjweaver 1.6.12
java -Xms256M -Xmx1024M -javaagent:lib/aspectjweaver.jar -Xbootclasspath/a:aspectjrt.jar:lib/javamoprt.jar:lib/mop/$1.jar -jar lib/dacapo-9.12-bach.jar $2
