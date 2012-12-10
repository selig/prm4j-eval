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

/**
 * Stores the current invocation and the confidence interval for previous invocations.
 */
public class SteadyStateEvaluation implements Serializable {

    private static final long serialVersionUID = -3377899252960634603L;

    private SteadyStateInvocation steadyStateInvocation;
    private final ConfidenceInterval confidenceInterval;

    public SteadyStateEvaluation() {
	confidenceInterval = new ConfidenceInterval(0.99D);
	steadyStateInvocation = new SteadyStateInvocation();
    }

    public SteadyStateInvocation getCurrentInvocation() {
	return steadyStateInvocation;
    }

    public ConfidenceInterval getConfidenceInterval() {
	return confidenceInterval;
    }

    public void closeCurrentInvocation() {
	confidenceInterval.addMeasurement(steadyStateInvocation.getMean());
	steadyStateInvocation = new SteadyStateInvocation();
    }

}
