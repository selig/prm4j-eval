package qea; 

import java.util.Iterator;
import java.util.Collection;
import java.util.concurrent.atomic.AtomicInteger;

//Imports for QEA
import static qea.structure.impl.other.Quantification.FORALL;
import qea.structure.intf.QEA;
import qea.creation.QEABuilder;
import qea.monitoring.impl.*;
import qea.monitoring.intf.*;
import qea.structure.impl.other.Verdict;
import qea.structure.intf.*;

public aspect SafeIteratorAspect {

        // Declaring the events 
        private final int ITERATOR = 1;
        private final int NEXT = 2;

	//The monitor
	Monitor monitor;
	private Object LOCK = new Object();


	@SuppressWarnings("unchecked")
	pointcut create(Collection c) : (call(Iterator Collection+.iterator()) && target(c));
	@SuppressWarnings("unchecked")
	pointcut next(Iterator i) :  call(* java.util.Iterator+.next()) && target(i);	
		
	@SuppressWarnings("unchecked")
	after(Collection c) returning(Iterator i): create(c) {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(ITERATOR,i,c.size())); 
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
		QEABuilder b = new QEABuilder("SafeIterator");	
		
		int i = -1;
		int size = 1;
		b.addQuantification(FORALL,i);
	
		b.addTransition(1,ITERATOR,new int[]{i,size},2);
		b.addTransition(2,NEXT,new int[]{i},Guard.varIsGreaterThanVal(size,0),
					 Assignment.decrement(size),2);

		b.addFinalStates(1,2);

		// Need to make with garbage reset
		monitor = MonitorFactory.create(b.make(),RestartMode.IGNORE,GarbageMode.LAZY);
	}


	public SafeIteratorAspect(){
		init();
		System.out.println("[qea.SafeIterator] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
                System.out.println("[qea.SafeIterator] Resetting... Reported " + MATCHES.get() + " matches.");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(MATCHES.get());

                MATCHES.set(0); // reset counter

                System.gc();
                System.gc();
        }


}


