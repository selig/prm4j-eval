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

import prm4j.api.Alphabet;
import prm4j.api.MatchHandler;
import prm4j.api.Parameter;
import prm4j.api.ParametricMonitor;
import prm4j.api.ParametricMonitorFactory;
import prm4j.api.Symbol1;
import prm4j.api.Symbol2;
import prm4j.api.MatchHandler.MatchCounter;
import prm4j.api.fsm.FSM;
import prm4j.api.fsm.FSMSpec;
import prm4j.api.fsm.FSMState;

import org.dacapo.harness.Callback;

/**
 * Standalone version (= with integrated fsm) of the UnsafeIterator pattern.
 */
@SuppressWarnings("rawtypes")
@SuppressAjWarnings({ "adviceDidNotMatch" })
public aspect UnsafeIterator extends Prm4jAspect {
    
    private final ParametricMonitor pm;
    private final Alphabet alphabet = new Alphabet();

    // parameters
    private final Parameter<Collection> c = alphabet.createParameter("c", Collection.class);
    private final Parameter<Iterator> i = alphabet.createParameter("i", Iterator.class);

    // symbols
    private final Symbol2<Collection, Iterator> createIter = alphabet.createSymbol2("createIter", c, i);
    private final Symbol1<Collection> updateColl = alphabet.createSymbol1("updateColl", c);
    private final Symbol1<Iterator> useIter = alphabet.createSymbol1("useIter", i);

    // match handler
    private final MatchCounter matchCounter = MatchHandler.MATCH_COUNTER;
    
    final FSM fsm = new FSM(alphabet);

    public UnsafeIterator() {
	
	
	
	// fsm states
	final FSMState initial = fsm.createInitialState();
	final FSMState s1 = fsm.createState();
	final FSMState s2 = fsm.createState();
	final FSMState error = fsm.createAcceptingState(matchCounter);

	// fsm transitions
	initial.addTransition(updateColl, initial);
	initial.addTransition(createIter, s1);
	s1.addTransition(useIter, s1);
	s1.addTransition(updateColl, s2);
	s2.addTransition(updateColl, s2);
	s2.addTransition(useIter, error);

	// parametric monitor creation
	pm = ParametricMonitorFactory.createParametricMonitor(new FSMSpec(fsm));
	
	System.out.println("[prm4j.UnsafeIterator] Created!");
    }

    after(Collection c) returning (Iterator i) : (call(Iterator Collection+.iterator()) && target(c)) && prm4jPointcut() {
	pm.processEvent(createIter.createEvent(c, i));
    }

    after(Collection c) : ((call(* Collection+.remove*(..)) || call(* Collection+.add*(..))) && target(c)) && prm4jPointcut() {
	pm.processEvent(updateColl.createEvent(c));
    }

    before(Iterator i) : (call(* Iterator.next()) && target(i)) && prm4jPointcut() {
	pm.processEvent(useIter.createEvent(i));
    }

    before() : execution (* Callback+.start(String)) {
	System.out.println("[prm4j.UnsafeIterator] Starting...");
    }

    before() : execution (* Callback+.stop()) {
	System.out.println("[prm4j.UnsafeIterator] Stopping and resetting...");
	matchCounter.getCounter().set(0);
	pm.reset();
	System.gc();
	System.gc();
    }

}
