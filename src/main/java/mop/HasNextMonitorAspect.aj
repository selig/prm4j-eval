package mop;
import java.util.Arrays;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.FileHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import javamoprt.MOPMonitor;

class HasNextMonitor_Set extends javamoprt.MOPSet {
	protected HasNextMonitor[] elementData;

	public HasNextMonitor_Set(){
		this.size = 0;
		this.elementData = new HasNextMonitor[4];
	}

	public final int size(){
		while(size > 0 && elementData[size-1].MOP_terminated) {
			elementData[--size] = null;
		}
		return size;
	}

	public final boolean add(MOPMonitor e){
		ensureCapacity();
		elementData[size++] = (HasNextMonitor)e;
		return true;
	}

	public final void endObject(int idnum){
		int numAlive = 0;
		for(int i = 0; i < size; i++){
			HasNextMonitor monitor = elementData[i];
			if(!monitor.MOP_terminated){
				monitor.endObject(idnum);
			}
			if(!monitor.MOP_terminated){
				elementData[numAlive++] = monitor;
			}
		}
		for(int i = numAlive; i < size; i++){
			elementData[i] = null;
		}
		size = numAlive;
	}

	public final boolean alive(){
		for(int i = 0; i < size; i++){
			MOPMonitor monitor = elementData[i];
			if(!monitor.MOP_terminated){
				return true;
			}
		}
		return false;
	}

	public final void endObjectAndClean(int idnum){
		int size = this.size;
		this.size = 0;
		for(int i = size - 1; i >= 0; i--){
			MOPMonitor monitor = elementData[i];
			if(monitor != null && !monitor.MOP_terminated){
				monitor.endObject(idnum);
			}
			elementData[i] = null;
		}
		elementData = null;
	}

	public final void ensureCapacity() {
		int oldCapacity = elementData.length;
		if (size + 1 > oldCapacity) {
			cleanup();
		}
		if (size + 1 > oldCapacity) {
			HasNextMonitor[] oldData = elementData;
			int newCapacity = (oldCapacity * 3) / 2 + 1;
			if (newCapacity < size + 1){
				newCapacity = size + 1;
			}
			elementData = Arrays.copyOf(oldData, newCapacity);
		}
	}

	public final void cleanup() {
		int numAlive = 0 ;
		for(int i = 0; i < size; i++){
			HasNextMonitor monitor = (HasNextMonitor)elementData[i];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;
			}
		}
		for(int i = numAlive; i < size; i++){
			elementData[i] = null;
		}
		size = numAlive;
	}

	public final void event_hasnext(Iterator i) {
		int numAlive = 0 ;
		for(int i_1 = 0; i_1 < this.size; i_1++){
			HasNextMonitor monitor = (HasNextMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_hasnext(i);
				if(monitor.Prop_1_Category_match) {
					monitor.Prop_1_handler_match(i);
				}
			}
		}
		for(int i_1 = numAlive; i_1 < this.size; i_1++){
			this.elementData[i_1] = null;
		}
		size = numAlive;
	}

	public final void event_next(Iterator i) {
		int numAlive = 0 ;
		for(int i_1 = 0; i_1 < this.size; i_1++){
			HasNextMonitor monitor = (HasNextMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_next(i);
				if(monitor.Prop_1_Category_match) {
					monitor.Prop_1_handler_match(i);
				}
			}
		}
		for(int i_1 = numAlive; i_1 < this.size; i_1++){
			this.elementData[i_1] = null;
		}
		size = numAlive;
	}
}

class HasNextMonitor extends javamoprt.MOPMonitor implements Cloneable, javamoprt.MOPObject {
    
    	/**
	 *  prm4j-eval: Measures number of matches.
	 */
    	static AtomicInteger MATCHES = new AtomicInteger(); // prm4j-eval
    	
	public Object clone() {
		try {
			HasNextMonitor ret = (HasNextMonitor) super.clone();
			return ret;
		}
		catch (CloneNotSupportedException e) {
			throw new InternalError(e.toString());
		}
	}

	int Prop_1_state;
	static final int Prop_1_transition_hasnext[] = {1, 1, 1, 3};;
	static final int Prop_1_transition_next[] = {2, 0, 2, 3};;

	boolean Prop_1_Category_match = false;

	public HasNextMonitor () {
		Prop_1_state = 0;

	}

	public final void Prop_1_event_hasnext(Iterator i) {
		MOP_lastevent = 0;

		Prop_1_state = Prop_1_transition_hasnext[Prop_1_state];
		Prop_1_Category_match = Prop_1_state == 2;
	}

	public final void Prop_1_event_next(Iterator i) {
		MOP_lastevent = 1;

		Prop_1_state = Prop_1_transition_next[Prop_1_state];
		Prop_1_Category_match = Prop_1_state == 2;
	}

	public final void Prop_1_handler_match (Iterator i){
		{
		    MATCHES.incrementAndGet(); // prm4j-eval
		}

	}

	public final void reset() {
		MOP_lastevent = -1;
		Prop_1_state = 0;
		Prop_1_Category_match = false;
	}

	public javamoprt.ref.MOPWeakReference MOPRef_i;

	//alive_parameters_0 = [Iterator i]
	public boolean alive_parameters_0 = true;

	public final void endObject(int idnum){
		switch(idnum){
			case 0:
			alive_parameters_0 = false;
			break;
		}
		switch(MOP_lastevent) {
			case -1:
			return;
			case 0:
			//hasnext
			//alive_i
			if(!(alive_parameters_0)){
				MOP_terminated = true;
				return;
			}
			break;

			case 1:
			//next
			//alive_i
			if(!(alive_parameters_0)){
				MOP_terminated = true;
				return;
			}
			break;

		}
		return;
	}

}

public aspect HasNextMonitorAspect implements javamoprt.MOPObject {
	javamoprt.map.MOPMapManager HasNextMapManager;
	private final MemoryLogger memoryLogger; // prm4j-eval
	public HasNextMonitorAspect(){
		HasNextMapManager = new javamoprt.map.MOPMapManager();
		HasNextMapManager.start();
		System.out.println("[JavaMOP.HasNext] Started"); // prm4j-eval
		memoryLogger = new MemoryLogger("logs/javaMOP-HasNext.log"); // prm4j-eval
	}

	// Declarations for the Lock
	static Object HasNext_MOPLock = new Object();

	static boolean HasNext_activated = false;

	// Declarations for Indexing Trees
	static javamoprt.map.MOPBasicRefMapOfMonitor HasNext_i_Map = new javamoprt.map.MOPBasicRefMapOfMonitor(0);
	static javamoprt.ref.MOPWeakReference HasNext_i_Map_cachekey_0 = javamoprt.map.MOPBasicRefMapOfMonitor.NULRef;
	static HasNextMonitor HasNext_i_Map_cachenode = null;

	// Trees for References
	static javamoprt.map.MOPRefMap HasNext_Iterator_RefMap = HasNext_i_Map;

	pointcut MOP_CommonPointCut() : !within(javamoprt.MOPObject+) && !adviceexecution();
	pointcut HasNext_hasnext(Iterator i) : (call(* Iterator.hasNext()) && target(i)) && MOP_CommonPointCut();
	after (Iterator i) : HasNext_hasnext(i) {
		HasNext_activated = true;
		synchronized(HasNext_MOPLock) {
		    	memoryLogger.logMemoryConsumption(); // prm4j-eval
			HasNextMonitor mainMonitor = null;
			javamoprt.map.MOPMap mainMap = null;
			javamoprt.ref.MOPWeakReference TempRef_i;

			// Cache Retrieval
			if (i == HasNext_i_Map_cachekey_0.get()) {
				TempRef_i = HasNext_i_Map_cachekey_0;

				mainMonitor = HasNext_i_Map_cachenode;
			} else {
				TempRef_i = HasNext_i_Map.getRef(i);
			}

			if (mainMonitor == null) {
				mainMap = HasNext_i_Map;
				mainMonitor = (HasNextMonitor)mainMap.getNode(TempRef_i);

				if (mainMonitor == null) {
					mainMonitor = new HasNextMonitor();

					mainMonitor.MOPRef_i = TempRef_i;

					HasNext_i_Map.putNode(TempRef_i, mainMonitor);
				}

				HasNext_i_Map_cachekey_0 = TempRef_i;
				HasNext_i_Map_cachenode = mainMonitor;
			}

			mainMonitor.Prop_1_event_hasnext(i);
			if(mainMonitor.Prop_1_Category_match) {
				mainMonitor.Prop_1_handler_match(i);
			}
		}
	}

	pointcut HasNext_next(Iterator i) : (call(* Iterator.next()) && target(i)) && MOP_CommonPointCut();
	before (Iterator i) : HasNext_next(i) {
		HasNext_activated = true;
		synchronized(HasNext_MOPLock) {
		    	memoryLogger.logMemoryConsumption(); // prm4j-eval
			HasNextMonitor mainMonitor = null;
			javamoprt.map.MOPMap mainMap = null;
			javamoprt.ref.MOPWeakReference TempRef_i;

			// Cache Retrieval
			if (i == HasNext_i_Map_cachekey_0.get()) {
				TempRef_i = HasNext_i_Map_cachekey_0;

				mainMonitor = HasNext_i_Map_cachenode;
			} else {
				TempRef_i = HasNext_i_Map.getRef(i);
			}

			if (mainMonitor == null) {
				mainMap = HasNext_i_Map;
				mainMonitor = (HasNextMonitor)mainMap.getNode(TempRef_i);

				if (mainMonitor == null) {
					mainMonitor = new HasNextMonitor();

					mainMonitor.MOPRef_i = TempRef_i;

					HasNext_i_Map.putNode(TempRef_i, mainMonitor);
				}

				HasNext_i_Map_cachekey_0 = TempRef_i;
				HasNext_i_Map_cachenode = mainMonitor;
			}

			mainMonitor.Prop_1_event_next(i);
			if(mainMonitor.Prop_1_Category_match) {
				mainMonitor.Prop_1_handler_match(i);
			}
		}
	}
	
	/**
	 *  prm4j-eval: resets the parametric monitor
	 */
	after() : execution (* org.dacapo.harness.Callback+.stop()) {
		System.out.println("[JavaMOP.HasNext] Resetting... Reported " + HasNextMonitor.MATCHES.get() + " violations.");
		HasNextMonitor.MATCHES.set(0); // reset counter
		
		HasNext_activated = false;

		HasNext_i_Map = new javamoprt.map.MOPBasicRefMapOfMonitor(0);
		HasNext_i_Map_cachekey_0 = javamoprt.map.MOPBasicRefMapOfMonitor.NULRef;
		HasNext_i_Map_cachenode = null;

		HasNext_Iterator_RefMap = HasNext_i_Map;
		
		HasNextMapManager = new javamoprt.map.MOPMapManager();
		HasNextMapManager.start();
		
		System.gc();
		System.gc();
		
	}
	
}
