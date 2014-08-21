package qea; 

import java.util.Iterator;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

//Imports for QEA
import static qea.structure.impl.other.Quantification.FORALL;
import qea.structure.intf.QEA;
import qea.creation.QEABuilder;
import qea.monitoring.impl.*;
import qea.monitoring.intf.*;
import qea.structure.impl.other.Verdict;

public aspect UnsafeMapIteratorCompetitionAspect {

        // Declaring the events 
        private final int CREATE = 1;
        private final int ITERATOR = 2;
        private final int USE = 3;
        private final int UPDATE = 4;

	//The monitor
	Monitor monitor;
	private Object LOCK = new Object();


	@SuppressWarnings("unchecked")
	pointcut create(Map map) : ((call(* Map.values()) || call(* Map.keySet())) && target(map));
	@SuppressWarnings("unchecked")
	pointcut iterator(Collection c) : (call(Iterator Collection+.iterator()) && target(c));
	@SuppressWarnings("unchecked")
	pointcut update(Map map) : ((call(* Map.put*(..)) || call(* Map.putAll*(..)) || call(* Map.clear()) || call(* Map.remove*(..))) && target(map));
	@SuppressWarnings("unchecked")
	pointcut next(Iterator i) : (call(* Iterator.next()) && target(i));
		

        @SuppressWarnings("unchecked")
        after (Map m) returning (Collection c) : create(m) {
                synchronized(LOCK){
                        memoryLogger.logMemoryConsumption(); // prm4j-eval
                        check(monitor.step(CREATE,m,c));
                }
        }

	@SuppressWarnings("unchecked")
	after (Collection c) returning (Iterator i) : iterator(c) {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(ITERATOR,c,i)); 
		}
        }
        @SuppressWarnings("unchecked")
        after(Map m) : update(m) {
                synchronized(LOCK){
                        memoryLogger.logMemoryConsumption(); // prm4j-eval
                        check(monitor.step(UPDATE,m));
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
			System.err.println("Error found, exiting...");
			report(true);
			System.exit(0);
		}
	}

	private final MemoryLogger memoryLogger; //prm4j-eval
	public void init(){
		QEABuilder b = new QEABuilder("UnsafeMapIterator");	
		
		int m = -1;
		int c = -2;
		int i = -3;

		b.addQuantification(FORALL, m);
		b.addQuantification(FORALL, c);
		b.addQuantification(FORALL, i);

		b.addTransition(1, CREATE, new int[] { m, c }, 2);
		b.addTransition(2, ITERATOR, new int[] { c, i }, 3);
		b.addTransition(3, UPDATE, new int[] { m }, 4);
		b.addTransition(4, USE, new int[] { i }, 5);

		b.setSkipStates(1, 2, 3, 4);
		b.addFinalStates(1, 2, 3, 4);

		QEA qea = b.make();

		// Set this optimisation, it's important but still experimental
		IncrementalMonitor.use_red=true;
		// Need to make with garbage reset
		monitor = MonitorFactory.create(b.make(),RestartMode.REMOVE,GarbageMode.UNSAFE_LAZY);
	}


	public UnsafeMapIteratorCompetitionAspect(){
		init();
		System.out.println("[qea.UnsafeMapIterator] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

	/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
		report(false);
	}

	public void report(boolean error){
                System.out.println("[qea.UnsafeMapIterator] Resetting... ");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(error ? 1 : 0);

                System.gc();
                System.gc();
        }


}


