/*
 * Copyright (c) 2012 Mateusz Parzonka, Eric Bodden
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Mateusz Parzonka - initial API and implementation
 */
package prm4jeval;

import java.io.File;
import java.util.Set;

import static java.util.Arrays.asList;

import com.google.common.collect.ArrayTable;

/**
 * Stores the evaluation data for all invocations. This object tries to load its data at the beginning, and serializes
 * its data state at the end of each invocation.
 */
public class EvaluationData {

    private final static String[] benchmarks = { "avrora", "batik", "eclipse", "fop", "h2", "luindex", "lusearch",
	    "pmd", "sunflow", "tomcat", "tradebeans", "tradesoap", "xalan" };
    private final static String[] parametricProperties = { "hasNext", "UnsafeIterator", "UnsafeMapIter",
	    "UnsafeSyncColl", "UnsafeSyncMap" };

    private final String filePath;
    private final ArrayTable<String, String, SteadyStateInvocation> data;

    /**
     * @param filePath
     *            the location where the evaluation object is written to.
     */
    public EvaluationData(String filePath) {
	this.filePath = filePath;
	final File file = new File(filePath);
	if (file.exists()) {
	    if (!file.isDirectory()) {
		data = loadEvaluationData();
	    } else {
		throw new IllegalArgumentException("There exists a directory at given filepath!");
	    }
	} else {
	    data = ArrayTable.create(asList(benchmarks), asList(parametricProperties));
	}
    }

    public Set<String> getBenchmarks() {
	return data.rowKeySet();
    }

    public Set<String> getParametricProperties() {
	return data.columnKeySet();
    }

    public SteadyStateInvocation getInvocation(String benchmark, String parametricProperty) {
	if (!getBenchmarks().contains(benchmark))
	    throw new IllegalArgumentException("Benchmark not known: " + benchmark);
	if (!getParametricProperties().contains(parametricProperty))
	    throw new IllegalArgumentException("Parametric property not known: " + parametricProperty);
	SteadyStateInvocation invocation = data.get(benchmark, parametricProperty);
	if (invocation == null) {
	    invocation = new SteadyStateInvocation();
	    data.put(benchmark, parametricProperty, invocation);
	    System.out.println("[prm4jeval] Created data for invocation: " + benchmark + "-" + parametricProperty);
	} else {
	    System.out.println("[prm4jeval] Retrieved data for invocation: " + benchmark + "-" + parametricProperty);
	}
	return invocation;
    }

    public void storeEvaluationData() {
	SerializationUtils.serializeToFile(data, filePath);
    }

    @SuppressWarnings("unchecked")
    public ArrayTable<String, String, SteadyStateInvocation> loadEvaluationData() {
	return (ArrayTable<String, String, SteadyStateInvocation>) SerializationUtils.deserializeFromFile(filePath);
    }

}
