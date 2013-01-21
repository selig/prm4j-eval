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

    public static void main(String[] args) {

	// => output normalized performance measures for all properties
	// - 0 -- 1 -- ---2 ----- 3 -- 4 ------ 5 --------- 6
	// [05, xalan, HasNext, mean, 08, 4456.400000, 0.017796]

	CITableWriter.writeCITable( //
		new TableParser2("logs/javamop.log") {
		    @Override
		    public void parseLine(String line) {
			String[] s = line.split(" ");
			if (s[3].equals("mean")) {
			    put(s[2], s[1], Double.parseDouble(s[5]) / 1000);
			}
		    }
		}, new TableParser1("logs/baseline.log") {
		    @Override
		    public void parseLine(String line) {
			String[] s = line.split(" ");
			if (s[3].equals("mean")) {
			    put(s[1], Double.parseDouble(s[5]) / 1000);
			}
		    }
		}, OUTPUT_PATH, "");

	// JAVAMOP => output normalized memory measures for all properties
	// - 0 -- 1 -- ---2 -------------- 3 ---- 4 ------- 5 ------ 6
	// - 0 -- 1 -- ---2 -------------- 3 --- mean ---- max -- events
	// [08 jython SafeSyncCollection iter 74.947705 88.861328 438394]

	final Set<String> skippedFirstLines = new HashSet<String>();
	CITableWriter.writeCITable( //
		new TableParser2("logs/javamop.log.mem.log") {
		    @Override
		    public void parseLine(String line) {
			String[] split = line.split(" ");
			// the first measurement of each invocation will not be counted (warm-up)
			if (!skippedFirstLines.add(split[0] + " " + split[1] + " " + split[2])) {
			    put(split[2], split[1], Double.parseDouble(split[4]));
			}
		    }
		}, OUTPUT_PATH, "mean");
	skippedFirstLines.clear();
	CITableWriter.writeCITable( //
		new TableParser2("logs/javamop.log.mem.log") {
		    @Override
		    public void parseLine(String line) {
			String[] split = line.split(" ");
			// the first measurement of each invocation will not be counted (warm-up)
			if (!skippedFirstLines.add(split[0] + " " + split[1] + " " + split[2])) {
			    put(split[2], split[1], Double.parseDouble(split[5]));
			}
		    }
		}, OUTPUT_PATH, "max");

    }

    public static <T> Set<T> set(T... values) {
	Set<T> set = new HashSet<T>();
	for (T s : values) {
	    set.add(s);
	}
	return set;
    }
}
