#!/usr/bin/env bash

mkdir -p bin/META-INF lib/mop lib/prm4j

sed 's/<aspectname>/mop.SafeMapIteratorMonitorAspect/g' resources/mop/aop-ajc.xml > bin/META-INF/aop-ajc.xml
jar cf lib/mop/SafeMapIterator.jar -C bin .

sed 's/<aspectname>/mop.SafeIteratorMonitorAspect/g' resources/mop/aop-ajc.xml > bin/META-INF/aop-ajc.xml
jar cf lib/mop/SafeIterator.jar -C bin .

rm bin/META-INF/aop-ajc.xml
