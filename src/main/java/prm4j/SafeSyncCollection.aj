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
import java.util.Collections;
import java.util.Iterator;
import java.util.logging.Level;

import org.aspectj.lang.annotation.SuppressAjWarnings;

import prm4j.api.Condition;
import prm4j.api.ParametricMonitor;
import prm4j.api.ParametricMonitorFactory;
import prm4j.api.fsm.FSMSpec;
import prm4j.indexing.realtime.AwareParametricMonitor;

import org.dacapo.harness.Callback;

@SuppressWarnings("rawtypes")
@SuppressAjWarnings({"adviceDidNotMatch"})
public aspect SafeSyncCollection extends Prm4jAspect {

    final FSM_SafeSyncCollection fsm;
    final ParametricMonitor pm;

    public SafeSyncCollection() {
	fsm = new FSM_SafeSyncCollection();
	pm = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm.fsm));
	System.out.println("prm4j: Parametric monitor for 'SafeSyncCollection' created!");
    }

    pointcut SafeSyncCollection_sync() :  (call(* Collections.synchr*(..))) && prm4jPointcut();

    after() returning (Collection c) : SafeSyncCollection_sync() {
	pm.processEvent(fsm.sync.createEvent(c));
    }

    pointcut SafeSyncCollection_syncCreateIter(Collection c) : (call(* Collection+.iterator()) && target(c) && if(Thread.holdsLock(c))) && prm4jPointcut();

    after(Collection c) returning (Iterator i) : SafeSyncCollection_syncCreateIter(c) {
	pm.processEvent(fsm.syncCreateIter.createEvent(c, i));
    }

    pointcut SafeSyncCollection_asyncCreateIter(Collection c) : (call(* Collection+.iterator()) && target(c) && if(!Thread.holdsLock(c))) && prm4jPointcut();

    after(Collection c) returning (Iterator i) : SafeSyncCollection_syncCreateIter(c) {
	pm.processEvent(fsm.asyncCreateIter.createEvent(c, i));
    }

    pointcut SafeSyncCollection_accessIter(Iterator i) : (call(* Iterator.*(..)) && target(i)) && prm4jPointcut();

    final Condition threadHoldsNoLockOnCollection = new Condition() {
	@Override
	public boolean eval() {
	    return !Thread.holdsLock(getParameterValue(fsm.c));
	}
    };

    before(Iterator i) : SafeSyncCollection_accessIter(i) {
	pm.processEvent(fsm.accessIter.createConditionalEvent(i, threadHoldsNoLockOnCollection));
    }

    before() : execution (* Callback+.stop()) {
	System.out.println("[prm4j.SafeSyncCollection] Stopping and resetting...");
	((AwareParametricMonitor) pm).getLogger().log(Level.INFO, "Matches: " + fsm.matchCounter.getCounter().get());
	fsm.matchCounter.getCounter().set(0);
	pm.reset();
	System.gc();
	System.gc();
    }
}
