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
package mop;

import java.util.logging.FileHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import org.apache.commons.math3.stat.descriptive.SummaryStatistics;

/**
 * Logs memory consumption to file. Activated by system property "prm4jeval.memoryLogging"
 */
public class MemoryLogger {

    private final static boolean MEMORY_LOGGING = Boolean.parseBoolean(getSystemProperty("prm4jeval.memoryLogging",
	    "false"));
    private long timestamp = 0L;
    private Logger logger;

    private String benchmark;
    private String parametricProperty;
    private int invocation;

    private SummaryStatistics memStats;

    MemoryLogger() {
	if (MEMORY_LOGGING) {
	    String outputPath = getMandatorySystemProperty("prm4jeval.outputfile") + ".mem.log";
	    System.out.println("Memory logging activated. Output path: " + outputPath);
	    benchmark = getMandatorySystemProperty("prm4jeval.benchmark");
	    parametricProperty = getMandatorySystemProperty("prm4jeval.parametricProperty");
	    invocation = Integer.parseInt(getMandatorySystemProperty("prm4jeval.invocation"));
	    logger = getFileLogger(outputPath);
	    memStats = new SummaryStatistics();
	} else {
	    System.out.println("Memory logging not activated.");
	}
    }

    public void logMemoryConsumption() {
	if (MEMORY_LOGGING && timestamp++ % 100 == 0) {
	    double memoryConsumption = (((double) (Runtime.getRuntime().totalMemory() / 1024) / 1024) - ((double) (Runtime
		    .getRuntime().freeMemory() / 1024) / 1024));
	    memStats.addValue(memoryConsumption);
	}
    }

    public void logMemoryConsumptionToFile() {
	if (MEMORY_LOGGING && timestamp++ % 100 == 0) {
	    logger.log(Level.INFO, timestamp
		    + " : "
		    + (((double) (Runtime.getRuntime().totalMemory() / 1024) / 1024) - ((double) (Runtime.getRuntime()
			    .freeMemory() / 1024) / 1024)));
	}
    }

    public void writeToFile() {
	if (MEMORY_LOGGING) {
	    logger.log(
		    Level.INFO,
		    String.format("%02d %s %s iter %f %f", invocation, benchmark, parametricProperty,
			    memStats.getMean(), memStats.getMax()));
	    memStats.clear();
	}
    }

    /**
     * A simple file logger which outputs only the message.
     *
     * @param fileName
     *            path to the output file
     * @return the logger
     */
    private static Logger getFileLogger(String fileName) {
	final Logger logger = Logger.getLogger(fileName);
	try {
	    logger.setUseParentHandlers(false);
	    Handler handler = new FileHandler(fileName, true);
	    handler.setFormatter(new Formatter() {
		@Override
		public String format(LogRecord record) {
		    return record.getMessage() + "\n";
		}
	    });
	    logger.addHandler(handler);
	} catch (Exception e) {
	    throw new RuntimeException(e);
	}
	return logger;
    }

    static String getSystemProperty(String key, String defaultValue) {
	final String value = System.getProperty(key);
	return value != null ? value : defaultValue;
    }

    static String getMandatorySystemProperty(String key) {
	final String value = System.getProperty(key);
	if (value == null) {
	    throw new RuntimeException("System property [" + key + "] is mandatory but not defined!");
	}
	return value;
    }

}
