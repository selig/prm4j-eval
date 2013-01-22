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

import java.util.Collection;
import java.util.Iterator;
import org.dacapo.harness.Callback;

import org.aspectj.lang.annotation.SuppressAjWarnings;

@SuppressWarnings("rawtypes")
@SuppressAjWarnings({ "adviceDidNotMatch" })
public aspect HasNext_SafeIterator extends Prm4jAspect {

    final FSM_HasNext fsm1;
    final ParametricMonitor pm1;
    final FSM_SafeIterator fsm2;
    final ParametricMonitor pm2;

    // HasNext
    
    public HasNext_SafeIterator() {
	fsm1 = new FSM_HasNext();
	pm1 = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm1.fsm));
	fsm2 = new FSM_SafeIterator();
	pm2 = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm2.fsm));
	System.out.println("[prm4j.HasNext+SafeIterator] Created!");
    }

    pointcut HasNext_hasnext(Iterator i) : call(* Iterator.hasNext()) && target(i) && prm4jPointcut();

    after(Iterator i) : HasNext_hasnext(i) {
	synchronized (this) {
	    pm1.processEvent(fsm1.hasNext.createEvent(i));
	}
    }

    pointcut HasNext_next(Iterator i) : call(* Iterator.next()) && target(i)  && prm4jPointcut();

    after(Iterator i) : HasNext_next(i) {
	synchronized (this) {
	    pm1.processEvent(fsm1.next.createEvent(i));
	}
    }

    // SafeIterator

    after(Collection c) returning (Iterator i) : (call(Iterator Collection+.iterator()) && target(c)) && prm4jPointcut() {
	synchronized (this) {
	    pm2.processEvent(fsm2.createIter.createEvent(c, i));
	}
    }

    after(Collection c) : ((call(* Collection+.remove*(..)) || call(* Collection+.add*(..))) && target(c)) && prm4jPointcut() {
	synchronized (this) {
	    pm2.processEvent(fsm2.updateColl.createEvent(c));
	}
    }

    before(Iterator i) : (call(* Iterator.next()) && target(i)) && prm4jPointcut() {
	synchronized (this) {
	    pm2.processEvent(fsm2.useIter.createEvent(i));
	}
    }

    before() : execution (* Callback+.start(String)) {
	System.out.println("[prm4j.HasNext+SafeIterator] Starting...");
    }

    before() : execution (* org.dacapo.harness.Callback+.stop()) {
	System.out.println("[prm4j.HasNext+SafeIterator] Stopping and resetting...");
	pm1.reset();
	pm2.reset();
	System.gc();
	System.gc();
    }

}
