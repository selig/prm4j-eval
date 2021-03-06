/**
 * NOTE - this uses a simplified version of HasNext that
 * does not check that hasNext returns true, as this is
 * the behaviour checked by prm4j
 */

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

public aspect HasNextAspect {

        // Declaring the events 
        private final int HASNEXT = 1;
        private final int NEXT = 2;

	//The monitor
	Monitor monitor;
	private Object LOCK = new Object();


	@SuppressWarnings("unchecked")
	pointcut hasNext(Iterator i) : call(* java.util.Iterator+.hasNext()) && target(i);
	@SuppressWarnings("unchecked")
	pointcut next(Iterator i) :  call(* java.util.Iterator+.next()) && target(i);	
		
	@SuppressWarnings("unchecked")
	after(Iterator i) returning(boolean b): hasNext(i) {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(HASNEXT,i)); 
		}
        }
        @SuppressWarnings("unchecked")
    	before(Iterator i) : next(i) {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(NEXT,i));
		}
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
		QEABuilder b = new QEABuilder("HasNext");	
		
		int i = -1;
		b.addQuantification(FORALL,i);
	
		b.addTransition(1,HASNEXT,i,2);
		b.addTransition(2,HASNEXT,i,2);
		b.addTransition(2,NEXT,i,1);

		b.addFinalStates(1,2);

		// Need to make with garbage reset
		monitor = MonitorFactory.create(b.make(),RestartMode.IGNORE,GarbageMode.LAZY);
	}


	public HasNextAspect(){
		init();
		System.out.println("[qea.HasNext] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
                System.out.println("[qea.HasNext] Resetting... Reported " + MATCHES.get() + " matches.");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(MATCHES.get());

                MATCHES.set(0); // reset counter

                System.gc();
                System.gc();
        }


}


