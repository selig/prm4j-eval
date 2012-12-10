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

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class ConfidenceIntervalTest {

    @Test
    public void getMean_getWidth() throws Exception {
	ConfidenceInterval ci = new ConfidenceInterval(0.99D);

	ci.addMeasurement(7010);
	ci.addMeasurement(7015);
	ci.addMeasurement(7005);
	ci.addMeasurement(7010);
	ci.addMeasurement(7015);
	ci.addMeasurement(7005);
	ci.addMeasurement(7010);
	ci.addMeasurement(7015);
	ci.addMeasurement(7005);
	ci.addMeasurement(7010);
	ci.addMeasurement(7015);
	ci.addMeasurement(7005);
	ci.addMeasurement(7010);
	ci.addMeasurement(7015);
	ci.addMeasurement(7005);

	assertEquals(7010, ci.getMean(), 0.0001D);
	assertEquals(3.248, ci.getWidth(), 0.0001D);
    }

}
