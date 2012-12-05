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

import java.util.Collection;
import java.util.Iterator;

import org.aspectj.lang.annotation.SuppressAjWarnings;

import prm4j.api.ParametricMonitor;
import prm4j.api.ParametricMonitorFactory;
import prm4j.api.fsm.FSMSpec;
import org.dacapo.harness.Callback;

@SuppressWarnings("rawtypes")
@SuppressAjWarnings({ "adviceDidNotMatch" })
public aspect UnsafeIterator {

    final FSM_UnsafeIterator fsm;
    final ParametricMonitor pm;

    public UnsafeIterator() {
	fsm = new FSM_UnsafeIterator();
	pm = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm.fsm));
	System.out.println("[prm4j.UnsafeIterator] Created!");
    }

    pointcut UnsafeIterator_create(Collection c) : (call(Iterator Collection+.iterator()) && target(c)) && !within(prm4j..*) && !within(org.dacapo..*);

    after(Collection c) returning (Iterator i) : UnsafeIterator_create(c) {
	pm.processEvent(fsm.create.createEvent(c, i));
    }

    pointcut UnsafeIterator_updatesource(Collection c) : ((call(* Collection+.remove*(..)) || call(* Collection+.add*(..))) && target(c)) && !within(prm4j..*) && !within(org.dacapo..*);

    after(Collection c) : UnsafeIterator_updatesource(c) {
	pm.processEvent(fsm.updateSource.createEvent(c));
    }

    pointcut UnsafeIterator_next(Iterator i) : (call(* Iterator.next()) && target(i)) && !within(prm4j..*) && !within(org.dacapo..*);

    before(Iterator i) : UnsafeIterator_next(i) {
	pm.processEvent(fsm.next.createEvent(i));
    }

    before() : call (* Callback+.start(String)) {
	System.out.println("[prm4j.UnsafeIterator] Starting...");
    }

    before() : call (* Callback+.stop()) {
	System.out.println("[prm4j.UnsafeIterator] Stopping and resetting...");
	pm.reset();
    }

}
