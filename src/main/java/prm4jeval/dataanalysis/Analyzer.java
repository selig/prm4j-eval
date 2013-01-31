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

import static org.apache.commons.io.FilenameUtils.concat;

import java.io.File;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.io.FilenameUtils;

/**
 * Perform analysis based on log files.
 */
public class Analyzer {

    /**
     * Run to perform the analysis and write analysis results into the output location(s).
     * 
     * @param args
     */
    public static void main(String[] args) {

	// Note that on mac the output directories have to exist!

	// the result folders for all variants in this folder are analyzed
	// note, that the evaluation is for a subset of the dacapo-benchmark, therefor it needs a different
	// baseline.log
	final String variantsInputPath = "logs/variants";
	final String variantsOutputPath = "data-analysis/variants";

	// the best variant is evaluated together with javamop
	final String finalInputPath = "logs/final";
	final String finalOutputPath = "data-analysis/final";

	// create output dirs (needed on osx)
	new File(finalOutputPath).mkdirs();
	new File(variantsOutputPath).mkdirs();

	for (File variant : new File(variantsInputPath).listFiles()) {
	    if (variant.isDirectory()) {
		final String variantPath = variant.getAbsolutePath();
		final File variantOutputPath = new File(concat(variantsOutputPath,
			FilenameUtils.getBaseName(variantPath)));
		variantOutputPath.mkdir();
		writeNormalizedSummedPerformanceTable(concat(variantPath, "prm4j.log"),
			concat(variantsInputPath, "baseline-small.log"), variantOutputPath.getAbsolutePath());
		writePrm4jStatsTables(concat(variantPath, "prm4j-stats.log"), variantOutputPath.getAbsolutePath());
	    }
	}

	// write benchmark means
	writeBaselinePerformanceTable(concat(finalInputPath, "baseline.log"), finalOutputPath);

	writeNormalizedPerformanceTable(concat(finalInputPath, "javamop.log"), concat(finalInputPath, "baseline.log"),
		finalOutputPath);
	writeJavaMOPStatsTables(concat(finalInputPath, "javamop-stats.log"), finalOutputPath);

	writeNormalizedPerformanceTable(concat(finalInputPath, "prm4j.log"), concat(finalInputPath, "baseline.log"),
		finalOutputPath);
	writePrm4jStatsTables(concat(finalInputPath, "prm4j-stats.log"), finalOutputPath);

    }

    private static void writePrm4jStatsTables(String logName, String outputPath) {
	writeStatsTable(logName, outputPath, "events", "EVENTS", 5);
	writeStatsTable(logName, outputPath, "matches", "MATCHES", 5);
	writeStatsTable(logName, outputPath, "memory-mean", "MEMORY", 5);
	writeStatsTable(logName, outputPath, "memory-max", "MEMORY", 6);
	writeStatsTable(logName, outputPath, "monitors-created", "MONITORS", 5);
	writeStatsTable(logName, outputPath, "monitors-updated", "MONITORS", 6);
	writeStatsTable(logName, outputPath, "monitors-ophaned", "MONITORS", 7);
	writeStatsTable(logName, outputPath, "monitors-collected", "MONITORS", 8);
	writeStatsTable(logName, outputPath, "bindings-created", "BINDINGS", 5);
	writeStatsTable(logName, outputPath, "bindings-collected", "BINDINGS", 6);
	writeStatsTable(logName, outputPath, "bindings-stored", "BINDINGS", 7);
    }

    private static void writeJavaMOPStatsTables(String logName, String outputPath) {
	writeStatsTable(logName, outputPath, "events", "EVENTS", 5);
	writeStatsTable(logName, outputPath, "matches", "MATCHES", 5);
	writeStatsTable(logName, outputPath, "memory-mean", "MEMORY", 5);
	writeStatsTable(logName, outputPath, "memory-max", "MEMORY", 6);
    }

    private static void writeBaselinePerformanceTable(String baselineLogName, String outputPath) {
	AnalysisResultsTableWriter.writeCITable(getRuntimeParser(baselineLogName), outputPath, "");
    }

    private static void writeNormalizedSummedPerformanceTable(String logName, String baseline, String outputPath) {
	AnalysisResultsTableWriter.writeSumTable( //
		new TableParser1(logName) {

		    @Override
		    public void parseLine(String line) {
			final String[] split = line.split("\\s+");
			if (split[3].equals("mean")) {
			    put(split[0] + " all all mean -", Double.parseDouble(split[5]));
			}
		    }

		}, outputPath, "summed");

	AnalysisResultsTableWriter.writeSumTable( //
		new TableParser1(baseline) {

		    @Override
		    public void parseLine(String line) {
			final String[] split = line.split("\\s+");
			if (split[3].equals("mean")) {
			    put(split[0] + " all all mean -", Double.parseDouble(split[5]));
			}
		    }

		}, outputPath, "summed");

	writeNormalizedPerformanceTable(
		FilenameUtils.concat(outputPath,
			FilenameUtils.getBaseName(logName) + "-summed." + FilenameUtils.getExtension(logName)),
		FilenameUtils.concat(outputPath,
			FilenameUtils.getBaseName(baseline) + "-summed." + FilenameUtils.getExtension(logName)),
		outputPath);

    }

    private static void writeStatsTable(final String logName, final String outputPath, final String tableName,
	    final String rowFilter, final int columnNr) {
	final Set<String> skippedFirstLines = new HashSet<String>();
	AnalysisResultsTableWriter.writeCITable( //
		new TableParser2(logName) {
		    @Override
		    public void parseLine(String line) {
			final String[] split = line.split("\\s+");
			if (split[3].equals(rowFilter)) {
			    // the first measurement of each invocation will not be counted (warm-up)
			    if (!skippedFirstLines.add(split[0] + " " + split[1] + " " + split[2])) {
				put(split[2], split[1], Double.parseDouble(split[columnNr]));
			    }
			}
		    }
		}, outputPath, tableName);
    }

    private static void writeNormalizedPerformanceTable(final String logName, final String baselinePath,
	    final String outputPath) {
	AnalysisResultsTableWriter.writeCITable( //
		new TableParser2(logName) {
		    @Override
		    public void parseLine(String line) {
			final String[] s = line.split("\\s+");
			if (s[3].equals("mean")) {
			    try {
				put(s[2], s[1], Double.parseDouble(s[5]) / 1000);
			    } catch (Exception e) {
				throw new RuntimeException("Problems reading line [" + line + "], parsing [" + s[5]
					+ "]");
			    }
			}
		    }
		}, getRuntimeParser(baselinePath), outputPath, "");
    }

    public static <T> Set<T> set(T... values) {
	final Set<T> set = new HashSet<T>();
	for (final T s : values) {
	    set.add(s);
	}
	return set;
    }

    public static TableParser1 getRuntimeParser(String logName) {
	return new TableParser1(logName) {
	    @Override
	    public void parseLine(String line) {
		final String[] s = line.split("\\s+");
		if (s[3].equals("mean")) {
		    put(s[1], Double.parseDouble(s[5]) / 1000);
		}
	    }
	};
    }
}
