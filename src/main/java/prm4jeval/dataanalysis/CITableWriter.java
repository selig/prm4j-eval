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
package prm4jeval.dataanalysis;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.io.FilenameUtils;

import com.google.common.collect.Multimap;

public class CITableWriter {

    private final static double confidenceLevel = 0.99D;

    /**
     * Writes a sum table
     * 
     * @param experimentParser
     * @param outputPath
     * @param comment
     */
    public static void writeSumTable(TableParser1 experimentParser, String outputPath, String comment) {
	final Multimap<String, Double> experiment = experimentParser.getResult();
	writeToFile(toStringDoubleMap(toOverheadSumMap(experiment)),
		toFilename(experimentParser, outputPath, optHyphen(comment)));
    }

    /**
     * Writes an unnormalized single table.
     * 
     * @param experimentParser
     * @param outputPath
     * @param comment
     */
    public static void writeCITable(TableParser1 experimentParser, String outputPath, String comment) {
	final Multimap<String, Double> experiment = experimentParser.getResult();
	writeToFile(toString(toConfidenceIntervalMap(experiment)), toFilename(experimentParser, outputPath, comment));
    }

    /**
     * Writes an unnormalized table collection.
     * 
     * @param experimentParser
     * @param outputPath
     * @param comment
     */
    public static void writeCITable(TableParser2 experimentParser, String outputPath, String comment) {
	Map<String, Multimap<String, Double>> experiment = experimentParser.getResult();
	for (String row : experiment.keySet()) {
	    writeToFile(toString(toConfidenceIntervalMap(experiment.get(row))),
		    toFilename(experimentParser, outputPath, optHyphen(row) + optHyphen(comment)));
	}
    }

    /**
     * Writes an normalized table collection.
     * 
     * @param experimentParser
     * @param outputPath
     */
    public static void writeCITable(TableParser2 experimentParser, TableParser1 baselineParser, String outputPath,
	    String comment) {
	final Multimap<String, Double> baseline = baselineParser.getResult();
	final Map<String, Multimap<String, Double>> experiment = experimentParser.getResult();
	for (String row : experiment.keySet()) {
	    writeToFile(
		    toString(toNormalizedConfidenceIntervalMap(toConfidenceIntervalMap(experiment.get(row)),
			    toConfidenceIntervalMap(baseline))),
		    toFilename(experimentParser, outputPath, optHyphen(row) + optHyphen(comment) + "-normalized"));
	}
    }

    private static String toFilename(LineParser parser, String outputPath, String additionalInfo) {
	return FilenameUtils.concat(outputPath, FilenameUtils.getBaseName(parser.getFilePath()) + additionalInfo
		+ ".log");
    }

    /**
     * @param string
     * @return prepends hyphen if string not-empty
     */
    private static String optHyphen(String string) {
	return string.isEmpty() ? "" : "-" + string;
    }

    /**
     * @param map
     * @return a table: <code>name 	mean 	error</code>
     */
    private static String toString(Map<String, Tuple<Double, Double>> map) {
	final StringBuilder sb = new StringBuilder();
	sb.append(String.format("%-12s  %16s  %16s\n", "name", "mean", "error"));
	for (String key : asSortedList(map.keySet())) {
	    final Tuple<Double, Double> tuple = map.get(key);
	    sb.append(String.format(Locale.US, "%-12s  %16f  %16f\n", key, tuple._1(), tuple._2()).toString());
	}
	return sb.toString();
    }

    private static String toStringDoubleMap(Map<String, Double> sumMap) {
	final StringBuilder sb = new StringBuilder();
	for (String invocation : asSortedList(sumMap.keySet())) {
	    final double sum = sumMap.get(invocation);
	    sb.append(String.format(Locale.US, "%s  %f\n", invocation, sum));
	}
	return sb.toString();
    }

    /**
     * @param mmap
     *            key -> {measurements}
     * @return key -> (mean, ci/2)
     */
    private final static Map<String, Tuple<Double, Double>> toConfidenceIntervalMap(Multimap<String, Double> mmap) {
	final Map<String, Tuple<Double, Double>> result = new HashMap<String, Tuple<Double, Double>>();
	for (String key : mmap.keySet()) {
	    final ConfidenceInterval confidenceInterval = new ConfidenceInterval(confidenceLevel);
	    for (Double measurement : mmap.get(key)) {
		confidenceInterval.addMeasurement(measurement);
	    }
	    result.put(key, Tuple.tuple(confidenceInterval.getMean(), confidenceInterval.getWidth() / 2));
	}
	return result;
    }

    /**
     * 
     * @param experiment
     *            key -> (mean, ci/2)
     * @param baseline
     *            key -> (mean, ci/2)
     * @return key -> (overhead in %, normalized ci/2)
     */
    private final static Map<String, Tuple<Double, Double>> toNormalizedConfidenceIntervalMap(
	    Map<String, Tuple<Double, Double>> experiment, Map<String, Tuple<Double, Double>> baseline) {
	final Map<String, Tuple<Double, Double>> result = new HashMap<String, Tuple<Double, Double>>();
	for (String key : experiment.keySet()) {
	    final Double experimentMean = experiment.get(key)._1();
	    final Double baselineMean = baseline.get(key)._1();
	    final Double ratio = (experimentMean / baselineMean) * 100;
	    final Double confidenceIntervalHalf = experiment.get(key)._2();
	    result.put(key, Tuple.tuple(ratio, confidenceIntervalHalf / ratio));
	}
	return result;
    }

    private static Map<String, Double> toOverheadSumMap(Multimap<String, Double> experiment) {
	final Map<String, Double> result = new HashMap<String, Double>();
	for (Entry<String, Collection<Double>> entry : experiment.asMap().entrySet()) {
	    result.put(entry.getKey(), sumCollection(entry.getValue()));
	}
	return result;
    }

    private static double sumCollection(Collection<Double> doubles) {
	double result = 0;
	for (Double d : doubles) {
	    result += d;
	}
	return result;
    }

    private static void writeToFile(String string, String outputPath) {
	PrintWriter out = null;
	try {
	    out = new PrintWriter(outputPath);
	    out.println(string);
	} catch (FileNotFoundException e) {
	    e.printStackTrace();
	} finally {
	    if (out != null) {
		out.close();
	    }
	}
    }

    private static <T extends Comparable<T>> List<T> asSortedList(Collection<T> c) {
	List<T> list = new ArrayList<T>(c);
	java.util.Collections.sort(list);
	return list;
    }

}
