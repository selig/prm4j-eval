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

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public abstract class TableParser1 extends LineParser {

    private final Multimap<String, Double> result;

    public TableParser1(String filePath) {
	super(filePath);
	result = ArrayListMultimap.create();
	parseFile();
    }

    @Override
    public abstract void parseLine(String line);

    public void put(String x, double value) {
	result.put(x, value);
    }

    public Multimap<String, Double> getResult() {
	return result;
    }

}
