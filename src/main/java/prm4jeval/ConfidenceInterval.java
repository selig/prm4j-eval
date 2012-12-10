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

import org.apache.commons.math3.distribution.RealDistribution;
import org.apache.commons.math3.distribution.TDistribution;
import org.apache.commons.math3.stat.descriptive.StatisticalSummary;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;

import com.google.common.primitives.Ints;

/**
 * Calculates the confidence interval based on Student's t-distribution.
 */
public class ConfidenceInterval implements Serializable {

    private static final long serialVersionUID = -6517007283853394393L;

    private SummaryStatistics measurements = new SummaryStatistics();
    private final double significance;

    public ConfidenceInterval(double confidenceLevel) {
	if (confidenceLevel < 0D || confidenceLevel > 1D) {
	    throw new IllegalArgumentException("ConfidenceLevel must be in [0, 1]");
	}
	significance = 1 - confidenceLevel;
    }

    public void addMeasurement(double value) {
	measurements.addValue(value);
    }

    public double getMean() {
	return measurements.getMean();
    }

    public int getNumberOfMeasurements() {
	return Ints.checkedCast(measurements.getN());
    }

    /**
     * Returns the width of the interval spanning around the mean. If c1 and c2 are the interval limits, the width is |c2
     * - c1|.
     *
     * @return the width of this confidence interval
     */
    public double getWidth() {
	return getConfidenceIntervalWidth(measurements, significance);
    }

    public static double getConfidenceIntervalWidth(StatisticalSummary summaryStatistics, double significance) {
	RealDistribution tDist = new TDistribution(summaryStatistics.getN() - 1);
	double t = tDist.inverseCumulativeProbability(1.0 - significance / 2);
	return 2 * t * summaryStatistics.getStandardDeviation() / Math.sqrt(summaryStatistics.getN());
    }

}
