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
package prm4j;

import prm4j.api.ParametricMonitor;
import prm4j.api.ParametricMonitorFactory;
import prm4j.api.fsm.FSMSpec;

import java.util.Iterator;

import org.aspectj.lang.annotation.SuppressAjWarnings;


@SuppressWarnings("rawtypes")
@SuppressAjWarnings({ "adviceDidNotMatch" })
public aspect HasNext extends Prm4jAspect {

    final FSM_HasNext fsm;
    final ParametricMonitor pm;

    public HasNext() {
	fsm = new FSM_HasNext();
	pm = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm.fsm));
	System.out.println("[prm4j.HasNext] Created!");
    }

    pointcut HasNext_hasnext(Iterator i) : call(* Iterator.hasNext()) && target(i) && prm4jPointcut();

    after(Iterator i) : HasNext_hasnext(i) {
	pm.processEvent(fsm.hasNext.createEvent(i));
    }

    pointcut HasNext_next(Iterator i) : call(* Iterator.next()) && target(i)  && prm4jPointcut();

    after(Iterator i) : HasNext_next(i) {
	pm.processEvent(fsm.next.createEvent(i));
    }

    before() : execution (* org.dacapo.harness.Callback+.stop()) {
	System.out.println("[prm4j.HasNext] Stopping and resetting...");
	pm.reset();
	System.gc();
	System.gc();
    }
    
}
