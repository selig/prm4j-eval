#!/usr/bin/env bash

# usage:         sh evalMOP <monitored property> <benchmark>

# example usage: sh evalMOP.sh SafeMapIterator avrora
#                sh evalMOP.sh SafeMapIterator h2
#                sh evalMOP.sh SafeIterator eclipse

# list of all monitored properties can be found in lib/mop; each jar is property
# list of all benchmarks can be found at http://dacapobench.org/benchmarks.html 

# remember directory where this script is called
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# create working and target directories
mkdir -p bin/META-INF target/mop target/prm4j

# compile the aspects into classes
ajc -cp $CLASSPATH:lib/javamoprt.jar src/mop/* -d bin -6

# create custom aop-ajc.xml and put in META-INF
sed 's/<aspectname>/mop.'$1'MonitorAspect/g' resources/mop/aop-ajc.xml > bin/META-INF/aop-ajc.xml

# repackage each aspect into a single jars with the custom aop-ajc.xml
jar cf target/mop/$1.jar -C bin META-INF/aop-ajc.xml -C bin mop/$1Monitor.class -C bin mop/$1Monitor_Set.class -C bin mop/$1MonitorAspect.class

# cleanup custom aop-ajc.xml
rm bin/META-INF/aop-ajc.xml

# load-time weaving via aspectjweaver 1.6.12
java -Xms256M -Xmx1024M -javaagent:${DIR}/lib/aspectjweaver.jar -Xbootclasspath/a:aspectjrt.jar:${DIR}/lib/javamoprt.jar:${DIR}/target/mop/$1.jar -jar lib/dacapo-9.12-bach.jar $2
