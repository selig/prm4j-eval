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
import java.util.Map;
import java.util.Set;

import org.aspectj.lang.annotation.SuppressAjWarnings;

import prm4j.api.Condition;
import prm4j.api.ParametricMonitor;
import prm4j.api.ParametricMonitorFactory;
import prm4j.api.fsm.FSMSpec;
import org.dacapo.harness.Callback;

@SuppressWarnings("rawtypes")
@SuppressAjWarnings({ "adviceDidNotMatch" })
public aspect SafeSyncMap extends Prm4jAspect {

    final FSM_SafeSyncMap fsm;
    final ParametricMonitor pm;

    public SafeSyncMap() {
	fsm = new FSM_SafeSyncMap();
	pm = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm.fsm));
	System.out.println("[prm4j.SafeSyncMap] Created!");
    }

    final Condition threadHoldsLockOnCollection = new Condition() {
	@Override
	public boolean eval() {
	    return Thread.holdsLock(getParameterValue(fsm.c));
	}
    };

    final Condition threadHoldsNoLockOnCollection = new Condition() {
	@Override
	public boolean eval() {
	    return !Thread.holdsLock(getParameterValue(fsm.c));
	}
    };

    pointcut SafeSyncMap_sync() : (call(* Collections.synchr*(..))) && prm4jPointcut();
    after () returning (Map syncMap) : SafeSyncMap_sync() {
	pm.processEvent(fsm.sync.createEvent(syncMap));
    }

    pointcut SafeSyncMap_createSet(Map syncMap) : (call(* Map+.keySet()) && target(syncMap)) && prm4jPointcut();
    after (Map syncMap) returning (Set mapSet) : SafeSyncMap_createSet(syncMap) {
	pm.processEvent(fsm.createSet.createEvent(syncMap, mapSet));
    }

    pointcut SafeSyncMap_createIter(Set mapSet) : (call(* Collection+.iterator()) && target(mapSet)) && prm4jPointcut();
    after(Set mapSet) returning (Iterator iter) : SafeSyncMap_createIter(mapSet) {
	pm.processEvent(fsm.syncCreateIter.createConditionalEvent(mapSet, iter, threadHoldsLockOnCollection));
	pm.processEvent(fsm.asyncCreateIter.createConditionalEvent(mapSet, iter, threadHoldsNoLockOnCollection));
    }

    pointcut SafeSyncCollection_accessIter(Iterator i) : (call(* Iterator.*(..)) && target(i)) && prm4jPointcut();
    before(Iterator i) : SafeSyncCollection_accessIter(i) {
	pm.processEvent(fsm.accessIter.createConditionalEvent(i, threadHoldsNoLockOnCollection));
    }

    after() : execution (* Callback+.stop()) {
	System.out.println("[prm4j.SafeSyncMap] Stopping and resetting...");
	pm.reset();
	System.gc();
	System.gc();
    }
}
