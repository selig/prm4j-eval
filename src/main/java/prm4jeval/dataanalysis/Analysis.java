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

import java.util.HashSet;
import java.util.Set;

/**
 * Perform analysis based on log files.
 */
public class Analysis {

    private final static String OUTPUT_PATH = "data-analysis";

    private final static TableParser1 BASELINE = new TableParser1("logs/final/baseline.log") {
	@Override
	public void parseLine(String line) {
	    final String[] s = line.split(" ");
	    if (s[3].equals("mean")) {
		put(s[1], Double.parseDouble(s[5]) / 1000);
	    }
	}
    };

    public static void main(String[] args) {

	// write benchmark means
	CITableWriter.writeCITable(BASELINE, OUTPUT_PATH, "");

	// write normalized performance values for all approaches
	writeNormalizedPerformanceTable("logs/final/javamop");
	writeNormalizedPerformanceTable("logs/final/prm4j");

	final Set<String> skippedFirstLines = new HashSet<String>();
	CITableWriter.writeCITable( //
		new TableParser2("logs/final/javamop.log.mem.log") {
		    @Override
		    public void parseLine(String line) {
			final String[] split = line.split(" ");
			// the first measurement of each invocation will not be counted (warm-up)
			if (!skippedFirstLines.add(split[0] + " " + split[1] + " " + split[2])) {
			    put(split[2], split[1], Double.parseDouble(split[4]));
			}
		    }
		}, OUTPUT_PATH, "mean");
	skippedFirstLines.clear();
	CITableWriter.writeCITable( //
		new TableParser2("logs/final/javamop.log.mem.log") {
		    @Override
		    public void parseLine(String line) {
			final String[] split = line.split(" ");
			// the first measurement of each invocation will not be counted (warm-up)
			if (!skippedFirstLines.add(split[0] + " " + split[1] + " " + split[2])) {
			    put(split[2], split[1], Double.parseDouble(split[5]));
			}
		    }
		}, OUTPUT_PATH, "max");

	writeStatsTable("logs/final/prm4j-stats", "matches", "MATCHES", 5);
	writeStatsTable("logs/final/prm4j-stats", "memory-mean", "MEMORY", 5);
	writeStatsTable("logs/final/prm4j-stats", "memory-max", "MEMORY", 6);
	writeStatsTable("logs/final/prm4j-stats", "monitors-created", "MONITORS", 5);
	writeStatsTable("logs/final/prm4j-stats", "monitors-updated", "MONITORS", 6);
	writeStatsTable("logs/final/prm4j-stats", "monitors-ophaned", "MONITORS", 7);
	writeStatsTable("logs/final/prm4j-stats", "monitors-collected", "MONITORS", 8);
	writeStatsTable("logs/final/prm4j-stats", "bindings-created", "BINDINGS", 5);
	writeStatsTable("logs/final/prm4j-stats", "bindings-collected", "BINDINGS", 6);
	writeStatsTable("logs/final/prm4j-stats", "bindings-stored", "BINDINGS", 7);
	writeStatsTable("logs/final/prm4j-stats", "events", "EVENTS", 5);

    }

    private static void writeStatsTable(final String logName, final String tableName, final String rowFilter,
	    final int columnNr) {
	final Set<String> skippedFirstLines = new HashSet<String>();
	CITableWriter.writeCITable( //
		new TableParser2(logName + ".log") {
		    @Override
		    public void parseLine(String line) {
			final String[] split = line.split(" ");
			if (split[3].equals(rowFilter)) {
			    // the first measurement of each invocation will not be counted (warm-up)
			    if (!skippedFirstLines.add(split[0] + " " + split[1] + " " + split[2])) {
				put(split[2], split[1], Double.parseDouble(split[columnNr]));
			    }
			}
		    }
		}, OUTPUT_PATH, tableName);
    }

    private static void writeNormalizedPerformanceTable(final String logName) {
	CITableWriter.writeCITable( //
		new TableParser2(logName + ".log") {
		    @Override
		    public void parseLine(String line) {
			final String[] s = line.split(" ");
			if (s[3].equals("mean")) {
			    put(s[2], s[1], Double.parseDouble(s[5]) / 1000);
			}
		    }
		}, BASELINE, OUTPUT_PATH, "");
    }

    public static <T> Set<T> set(T... values) {
	final Set<T> set = new HashSet<T>();
	for (final T s : values) {
	    set.add(s);
	}
	return set;
    }
}
