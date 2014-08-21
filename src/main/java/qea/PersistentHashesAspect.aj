package qea; 

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

//Imports for QEA
import static qea.structure.impl.other.Quantification.FORALL;
import qea.structure.intf.QEA;
import qea.creation.QEABuilder;
import qea.monitoring.impl.*;
import qea.monitoring.intf.*;
import qea.structure.impl.other.Verdict;
import qea.structure.intf.*;

public aspect PersistentHashesAspect {

        // Declaring the events 
        private final int ADD = 1;
        private final int OBSERVE = 2;
        private final int REMOVE = 3;

	//The monitor
	Monitor monitor;

	 @SuppressWarnings("unchecked")
        after(HashSet t, Object o) returning(Boolean b) : call(* Collection+.add(Object)) && target(t) && args(o)  {
                synchronized(monitor){check(monitor.step(ADD,o,o.hashCode(),b));}
        }
        @SuppressWarnings("unchecked")
        after(HashMap t, Object o) returning(Boolean b) : call(* Map+.put(Object,Object)) && target(t) && args(o,*) {
                synchronized(monitor){check(monitor.step(ADD,o,o.hashCode(),b));}
        }

        @SuppressWarnings("unchecked")
        after(HashSet t, Object o) : call(* Collection+.contains(Object)) && target(t) && args(o) {
                synchronized(monitor){check(monitor.step(OBSERVE,o,o.hashCode()));}
        }

        @SuppressWarnings("unchecked")
        after(HashMap t, Object o) : call(* Map+.containsKey(Object)) && target(t) && args(o) {
                synchronized(monitor){check(monitor.step(OBSERVE,o,o.hashCode()));}
        }

        @SuppressWarnings("unchecked")
        after(HashMap t, Object o) : call(* Map+.get(Object)) && target(t) && args(o) {
                synchronized(monitor){check(monitor.step(OBSERVE,o,o.hashCode()));}
        }


        @SuppressWarnings("unchecked")
        after(HashSet t, Object o) returning(Boolean b) : call(* Collection+.remove(Object)) && target(t) && args(o){
                synchronized(monitor){check(monitor.step(REMOVE,o,o.hashCode(),b));}
        }

        @SuppressWarnings("unchecked")
        after(HashMap t, Object o) returning(Boolean b) : call(* Map+.remove(Object)) && target(t) && args(o) {
                synchronized(monitor){check(monitor.step(REMOVE,o,o.hashCode(),b));}
        }


	private static void check(Verdict verdict){
		if(verdict==Verdict.FAILURE){
			//System.err.println("Error detected, exiting...");
			MATCHES.incrementAndGet();
		}
	}

	private final MemoryLogger memoryLogger; //prm4j-eval
	private static AtomicInteger MATCHES = new AtomicInteger(); //prm4j-eval
	public void init(){
		QEABuilder b = new QEABuilder("PersistentHashes");	
		
		int o = -1;

		int hash = 1;
		int count_inside = 2;
		int success = 3;
		int hash_new = 4;


		b.addQuantification(FORALL, o);

		b.addTransition(1,ADD,new int[]{o,hash,success},
					Guard.isTrue(success),
					Assignment.setVal(count_inside,1),
				2);
		b.addTransition(2,ADD,new int[]{o,hash_new,success},
					Guard.and(Guard.isTrue(success),
						  Guard.isEqualSem(hash,hash_new)),
					Assignment.increment(count_inside),
				2);
		b.addTransition(2,REMOVE,new int[]{o,hash_new,success},
					Guard.and(Guard.and(Guard.isTrue(success),
						  	    Guard.isGreaterThanConstant(count_inside,1)),
						  Guard.isEqualSem(hash,hash_new)),
					Assignment.decrement(count_inside),
				2);
		b.addTransition(2,REMOVE,new int[]{o,hash_new,success},
					Guard.and(Guard.and(Guard.isTrue(success),
							Guard.isSemEqualToConstant(count_inside, 1)),
					Guard.isEqualSem(hash, hash_new)),
					Assignment.decrement(count_inside),
				1);
		b.addTransition(2,OBSERVE,new int[]{o,hash_new},
					Guard.isEqualSem(hash, hash_new),
				2);

		b.addFinalStates(1, 2);

		// Need to make with garbage reset
		monitor = MonitorFactory.create(b.make(),RestartMode.IGNORE,GarbageMode.LAZY);
	}


	public PersistentHashesAspect(){
		init();
		System.out.println("[qea.PersistentHashes] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
                System.out.println("[qea.PersistentHashes] Resetting... Reported " + MATCHES.get() + " matches.");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(MATCHES.get());

                MATCHES.set(0); // reset counter

                System.gc();
                System.gc();
        }


}


