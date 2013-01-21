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

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public abstract class LineParser {

    private final BufferedReader reader;
    private final String filePath;

    public LineParser(String filePath) {
	this.filePath = filePath;
	try {
	    reader = new BufferedReader(new FileReader(filePath));
	} catch (FileNotFoundException e) {
	    throw new RuntimeException(e);
	}
    }

    public void parseFile() {
	String myLine = null;
	try {
	    while ((myLine = reader.readLine()) != null) {
		parseLine(myLine);
	    }
	} catch (IOException e) {
	    e.printStackTrace();
	}
    }

    public abstract void parseLine(String line);

    public String getFilePath() {
	return filePath;
    }

}
