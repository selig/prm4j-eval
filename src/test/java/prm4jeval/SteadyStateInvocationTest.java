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

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Before;
import org.junit.Test;

public class SteadyStateInvocationTest {

    SteadyStateInvocation ssi;

    @Before
    public void init() {
	ssi = new SteadyStateInvocation(5, 0.2D);
    }

    @Test
    public void isThresholdReached_window1() throws Exception {
	ssi.addMeasurement(8000);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8002);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8005);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8001);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8003);
	assertTrue(ssi.isThresholdReached());
    }

    @Test
    public void isThresholdReached_window2() throws Exception {
	ssi.addMeasurement(8001);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8002);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(42);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8004);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8001);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8004);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8002);
	assertFalse(ssi.isThresholdReached());
	ssi.addMeasurement(8009);
	assertTrue(ssi.isThresholdReached());
    }

}
