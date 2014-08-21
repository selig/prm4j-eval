package qea; 

import java.util.Iterator;
import java.util.concurrent.atomic.AtomicInteger;

//Imports for QEA
import static qea.structure.impl.other.Quantification.FORALL;
import qea.structure.intf.QEA;
import qea.creation.QEABuilder;
import qea.monitoring.impl.*;
import qea.monitoring.intf.*;
import qea.structure.impl.other.Verdict;
import qea.structure.intf.*;

public aspect LockOrderingAspect {

        // Declaring the events 
        private final int LOCK = 1;
        private final int UNLOCK = 2;

	//The monitor
	Monitor monitor;
	private Object LOCK_OBJ = new Object();

        @SuppressWarnings("unchecked")
        before(Object l) : lock() && args(l) && !within(qea.*)  {
		synchronized(LOCK_OBJ){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(LOCK,l)); 
		}
        }

        @SuppressWarnings("unchecked")
        before(Object l) : unlock() && args(l) && !within(qea.*) {
		synchronized(LOCK_OBJ){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(UNLOCK,l)); 
		}
        }
		

	private static void check(Verdict verdict){
		if(verdict==Verdict.FAILURE){
			MATCHES.incrementAndGet();
		}
	}

	private final MemoryLogger memoryLogger; //prm4j-eval
	private static AtomicInteger MATCHES = new AtomicInteger(); //prm4j-eval
	public void init(){
		QEABuilder b = new QEABuilder("LockOrdering");	
		
		int l1 = -1;
		int l2 = -2;

		b.addQuantification(FORALL, l1);
		b.addQuantification(FORALL, l2, Guard.isIdentityLessThan(l1, l2));

		// As we use next states we'll be symmetric
		// which is why we have the < global guard

		// l1 goes first
		b.addTransition(1, LOCK, l1, 2);
		b.addTransition(2, UNLOCK, l1, 1);
		b.addTransition(2, LOCK, l2, 3);
		b.addTransition(3, UNLOCK, l2, 3);
		b.addTransition(3, LOCK, l1, 3);
		b.addTransition(3, UNLOCK, l1, 3);
		b.addTransition(3, LOCK, l2, 4);
		b.addTransition(4, UNLOCK, l2, 3);
		b.addTransition(4, LOCK, l1, 5); // State 5 is failure

		// l2 goes first
		b.addTransition(1, LOCK, l2, 6);
		b.addTransition(6, UNLOCK, l2, 1);
		b.addTransition(6, LOCK, l1, 7);
		b.addTransition(7, UNLOCK, l1, 7);
		b.addTransition(7, LOCK, l2, 7);
		b.addTransition(7, UNLOCK, l2, 7);
		b.addTransition(7, LOCK, l1, 8);
		b.addTransition(8, UNLOCK, l1, 7);
		b.addTransition(8, LOCK, l2, 5); // State 5 is failure

		b.addFinalStates(1, 2, 3, 4, 6, 7, 8);

		monitor = MonitorFactory.create(b.make(),RestartMode.REMOVE,GarbageMode.UNSAFE_LAZY);
	}


	public LockOrderingAspect(){
		init();
		System.out.println("[qea.LockOrdering] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
                System.out.println("[qea.LockOrdering] Resetting... Reported " + MATCHES.get() + " matches.");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(MATCHES.get());

                MATCHES.set(0); // reset counter

                System.gc();
                System.gc();
        }


}


