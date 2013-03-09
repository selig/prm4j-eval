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

import java.io.Serializable;

import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

public class SteadyStateInvocation implements Serializable {

    private static final long serialVersionUID = -5341292262089739659L;

    /**
     * When the coefficient of standard deviation falls below this value, we have entered steady state.
     */
    protected final double covThreshold;
    protected final int window;
    protected int iteration;
    private final DescriptiveStatistics measurements;
    private final int maxIterations;

    public SteadyStateInvocation(int window, double covThreshold, int maxIterations) {
	this.window = window;
	this.covThreshold = covThreshold;
	this.maxIterations = maxIterations;
	measurements = new DescriptiveStatistics(window);
    }

    public SteadyStateInvocation() {
	window = Integer.parseInt(getSystemProperty("prm4jeval.window", "5"));
	covThreshold = Double.parseDouble(getSystemProperty("prm4jeval.covThreshold", "0.02"));
	maxIterations = Integer.parseInt(getSystemProperty("prm4jeval.maxIterations", "25"));
	System.out.println("maxiterations=" + maxIterations);
	measurements = new DescriptiveStatistics(window);
    }

    /**
     * 
     * @param time
     * @return <code>true</code> if more measurements are needed
     */
    public boolean addMeasurement(long time) {
	iteration++;
	final double value = new Long(time).doubleValue();
	measurements.addValue(value);
	return isThresholdReached();
    }

    /**
     * @return true if we have enough measurements for this invocation.
     */
    public boolean isThresholdReached() {
	if (maxIterations >= window) {
	    if (measurements.getN() < window) {
		return false;
	    }
	    double cov = getCoefficientOfStandardDeviation();
	    if (cov < covThreshold) {
		System.out.println("Reached cov-threshold: " + cov);
		return true;
	    }
	    if (iteration >= maxIterations) {
		System.out.println("Performed " + maxIterations + " iterations, proceeding with cov=" + cov
			+ " and mean of last " + window + " measurements: " + measurements.getMean());
		return true;
	    }
	} else {
	    if (iteration >= maxIterations) {
		System.out.println("Performed " + maxIterations + " iterations, proceeding with cov="
			+ getCoefficientOfStandardDeviation() + " and mean of last " + iteration + " measurements: "
			+ measurements.getMean()
			+ " Warning: The number of maxIterations was smaller than the window size.");
		return true;
	    }
	}
	return false;
    }

    public double getCoefficientOfStandardDeviation() {
	double standardDeviation = measurements.getStandardDeviation();
	double mean = measurements.getMean();
	return standardDeviation / mean;
    }

    /**
     * @return the mean of the measurements
     */
    public double getMean() {
	return measurements.getMean();
    }

    /**
     * @return the measurementCount
     */
    public long getMeasurementCount() {
	return measurements.getN();
    }

    static String getSystemProperty(String key, String defaultValue) {
	final String value = System.getProperty(key);
	return value != null ? value : defaultValue;
    }

}
