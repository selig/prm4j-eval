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

public aspect SafeSyncCollectionAspect {

        // Declaring the events 
        private static final int ASYNC_ITERATOR = 1;
        private static final int SYNC_ITERATOR = 2;
        private static final int USE = 3;
	private static final int CREATE = 4;

	//The monitor
	Monitor monitor;
	private Object LOCK = new Object();




	@SuppressWarnings("unchecked")
	after()  returning(Object c) :  call(* Collections.synchr*(..))  {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(CREATE,c)); 
		}
        }

	@SuppressWarnings("unchecked")
        after(Object c)  returning(Iterator i) :  call(* Collection+.iterator()) &&  if(Thread.holdsLock(c )) && target( c )  {
		synchronized(LOCK){
			memoryLogger.logMemoryConsumption(); // prm4j-eval
			check(monitor.step(SYNC_ITERATOR,c,i));
		}
       }

        @SuppressWarnings("unchecked")
        after(Object c)  returning(Iterator i) :  call(* Collection+.iterator()) &&  if(!Thread.holdsLock(c )) && target(c)   {
                synchronized(LOCK){
                        memoryLogger.logMemoryConsumption(); // prm4j-eval
                        check(monitor.step(ASYNC_ITERATOR,c,i));
                }
       }

        @SuppressWarnings("unchecked")
        before(Iterator i) : (call(* Iterator+.*(..)) || call(* Iterator+.*())) && target(i)  {
                synchronized(LOCK){
                	//condition(!Thread.holdsLock(this.c))
                        memoryLogger.logMemoryConsumption(); // prm4j-eval
                        check(monitor.step(USE,i));
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
		QEABuilder b = new QEABuilder("SafeSyncCollection");	
		
		final int c = -1;
		final int i = -2;

		Guard notHoldsLock = new Guard("!Thread.holdsLock(c)"){
			public boolean check(Binding b){
				return !Thread.holdsLock(b.getForced(c));
			}
			public boolean check(Binding b, int qv, Object o){ 
				if(qv==c) return !Thread.holdsLock(o);
				else return check(b);
			}
			public boolean usesQvars(){ return true; }
			public int[] vars(){ return new int[]{c};}
		};

		b.addQuantification(FORALL,c);
		b.addQuantification(FORALL,i);

		b.addTransition(1,CREATE,c,2);
		b.addTransition(2,ASYNC_ITERATOR,new int[]{c,i},3);
		b.addTransition(2,SYNC_ITERATOR,new int[]{c,i},4);
		b.addTransition(4,USE,new int[]{i},notHoldsLock,5);


		b.setSkipStates(1,2,3,4,5);
		b.addFinalStates(1,2,4);
		

		QEA qea = b.make();

		// Set this optimisation, it's important but still experimental
		IncrementalMonitor.use_red=true;
		// Need to make with garbage reset
		monitor = MonitorFactory.create(b.make(),RestartMode.REMOVE,GarbageMode.UNSAFE_LAZY);
	}


	public SafeSyncCollectionAspect(){
		init();
		System.out.println("[qea.SafeSyncCollection] Started"); //prm4j-eval
		memoryLogger = new MemoryLogger(); // prm4j-eval
	}

	/**
         *  prm4j-eval: resets the parametric monitor
         */
        after() : execution (* org.dacapo.harness.Callback+.stop()) {
                System.out.println("[qea.SafeSyncCollection] Resetting... Reported " + MATCHES.get() + " matches.");

                memoryLogger.reallyLogMemoryConsumption(); // so we have at least two values

		init();

                memoryLogger.writeToFile(MATCHES.get());

                MATCHES.set(0); // reset counter

                System.gc();
                System.gc();
        }


}


