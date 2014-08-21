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

public aspect UnsafeIteratorCompetitionAspect {

        // Declaring the events 
        private final int ITERATOR = 1;
        private final int USE = 2;
        private final int UPDATE = 3;

	//The monitor
	Monitor monitor;
	private Object LOCK = new Object();


	@SuppressWarnings("unchecked")
	pointcut create(Collection c) : (call(Iterator Collection+.iterator()) && target(c));
	@SuppressWarnings("unchecked")
 	pointcut update(Collection c) : ((call(* Collection+.remove*(..)) || call(* Collection+.add*(..))) && target(c));
	@SuppressWarnings("unchecked")
	pointcut next(Iterator i) : (call(* Iterator.next()) && target(i));
		
	@SuppressWarnings("unchecked")
	after (Collection c) returning (Iterator i) : create(c) {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(ITERATOR,c,i)); 
		}
        }
        @SuppressWarnings("unchecked")
        after(Collection c) : update(c) {
                synchronized(LOCK){
                        memoryLogger.logMemoryConsumption(); // prm4j-eval
                        check(monitor.step(UPDATE,c));
                }
        }
        @SuppressWarnings("unchecked")
    	before(Iterator i) : next(i) {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(USE,i));
		}
        }

	private void check(Verdict verdict){
		if(verdict==Verdict.FAILURE){
			System.err.println("Error found, exiting..");
			report(true);
			System.exit(0);
		}
	}

	private final MemoryLogger memoryLogger; //prm4j-eval
	public void init(){
		QEABuilder b = new QEABuilder("UnsafeIterator");	
		
		int c = -1;
		int i = -2;

		b.addQuantification(FORALL, c);
		b.addQuantification(FORALL, i);

		b.addTransition(1, ITERATOR, new int[] { c, i }, 2);
		b.addTransition(2, UPDATE, new int[] { c }, 3);
		b.addTransition(3, USE, new int[] { i }, 4);

		b.setSkipStates(1, 2, 3);
		b.addFinalStates(1, 2, 3);

		QEA qea = b.make();

		// Set this optimisation, it's important but still experimental
		IncrementalMonitor.use_red=true;
		// Need to make with garbage reset
		monitor = MonitorFactory.create(b.make(),RestartMode.REMOVE,GarbageMode.UNSAFE_LAZY);
	}


	public UnsafeIteratorCompetitionAspect(){
		init();
		System.out.println("[qea.UnsafeIterator] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

	/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
		report(false);
	}

	public void report(boolean error){
                System.out.println("[qea.UnsafeIterator] Resetting... ");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(error ? 1 : 0);

                System.gc();
                System.gc();
        }


}


