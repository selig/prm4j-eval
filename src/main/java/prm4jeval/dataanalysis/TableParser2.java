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

import java.util.HashMap;
import java.util.Map;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public abstract class TableParser2 extends LineParser {

    private final Map<String, Multimap<String, Double>> result;

    public TableParser2(String filePath) {
	super(filePath);
	result = new HashMap<String, Multimap<String, Double>>();
	parseFile();
    }

    @Override
    public abstract void parseLine(String line);

    public void put(String x, String y, double value) {
	Multimap<String, Double> multimap = result.get(x);
	if (multimap == null) {
	    multimap = ArrayListMultimap.create();
	    result.put(x, multimap);
	}
	multimap.put(y, value);
    }

    public Map<String, Multimap<String, Double>> getResult() {
	return result;
    }

}
