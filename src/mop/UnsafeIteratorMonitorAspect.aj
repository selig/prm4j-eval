package mop;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.locks.*;
import javamoprt.*;
import java.lang.ref.*;
import org.aspectj.lang.*;

class UnsafeIteratorMonitor_Set extends javamoprt.MOPSet {
	protected UnsafeIteratorMonitor[] elementData;

	public UnsafeIteratorMonitor_Set(){
		this.size = 0;
		this.elementData = new UnsafeIteratorMonitor[4];
	}

	public final int size(){
		while(size > 0 && elementData[size-1].MOP_terminated) {
			elementData[--size] = null;
		}
		return size;
	}

	public final boolean add(MOPMonitor e){
		ensureCapacity();
		elementData[size++] = (UnsafeIteratorMonitor)e;
		return true;
	}

	public final void endObject(int idnum){
		int numAlive = 0;
		for(int i = 0; i < size; i++){
			UnsafeIteratorMonitor monitor = elementData[i];
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
			UnsafeIteratorMonitor[] oldData = elementData;
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
			UnsafeIteratorMonitor monitor = (UnsafeIteratorMonitor)elementData[i];
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

	public final void event_create(Collection c, Iterator i) {
		int numAlive = 0 ;
		for(int i_1 = 0; i_1 < this.size; i_1++){
			UnsafeIteratorMonitor monitor = (UnsafeIteratorMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_create(c, i);
				if(monitor.Prop_1_Category_match) {
					monitor.Prop_1_handler_match(c, i);
				}
			}
		}
		for(int i_1 = numAlive; i_1 < this.size; i_1++){
			this.elementData[i_1] = null;
		}
		size = numAlive;
	}

	public final void event_updatesource(Collection c) {
		int numAlive = 0 ;
		for(int i_1 = 0; i_1 < this.size; i_1++){
			UnsafeIteratorMonitor monitor = (UnsafeIteratorMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_updatesource(c);
				if(monitor.Prop_1_Category_match) {
					monitor.Prop_1_handler_match(c, null);
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
			UnsafeIteratorMonitor monitor = (UnsafeIteratorMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_next(i);
				if(monitor.Prop_1_Category_match) {
					monitor.Prop_1_handler_match(null, i);
				}
			}
		}
		for(int i_1 = numAlive; i_1 < this.size; i_1++){
			this.elementData[i_1] = null;
		}
		size = numAlive;
	}
}

class UnsafeIteratorMonitor extends javamoprt.MOPMonitor implements Cloneable, javamoprt.MOPObject {
	public long tau = -1;
	public Object clone() {
		try {
			UnsafeIteratorMonitor ret = (UnsafeIteratorMonitor) super.clone();
			return ret;
		}
		catch (CloneNotSupportedException e) {
			throw new InternalError(e.toString());
		}
	}

	int Prop_1_state;
	static final int Prop_1_transition_create[] = {1, 4, 4, 4, 4};;
	static final int Prop_1_transition_updatesource[] = {4, 2, 2, 4, 4};;
	static final int Prop_1_transition_next[] = {4, 1, 3, 4, 4};;

	boolean Prop_1_Category_match = false;

	public UnsafeIteratorMonitor () {
		Prop_1_state = 0;

	}

	public final void Prop_1_event_create(Collection c, Iterator i) {
		MOP_lastevent = 0;

		Prop_1_state = Prop_1_transition_create[Prop_1_state];
		Prop_1_Category_match = Prop_1_state == 3;
	}

	public final void Prop_1_event_updatesource(Collection c) {
		MOP_lastevent = 1;

		Prop_1_state = Prop_1_transition_updatesource[Prop_1_state];
		Prop_1_Category_match = Prop_1_state == 3;
	}

	public final void Prop_1_event_next(Iterator i) {
		MOP_lastevent = 2;

		Prop_1_state = Prop_1_transition_next[Prop_1_state];
		Prop_1_Category_match = Prop_1_state == 3;
	}

	public final void Prop_1_handler_match (Collection c, Iterator i){
		{
			System.out.println("improper iterator usage");
		}

	}

	public final void reset() {
		MOP_lastevent = -1;
		Prop_1_state = 0;
		Prop_1_Category_match = false;
	}

	public javamoprt.ref.MOPTagWeakReference MOPRef_c;
	public javamoprt.ref.MOPTagWeakReference MOPRef_i;

	//alive_parameters_0 = [Collection c, Iterator i]
	public boolean alive_parameters_0 = true;
	//alive_parameters_1 = [Iterator i]
	public boolean alive_parameters_1 = true;

	public final void endObject(int idnum){
		switch(idnum){
			case 0:
			alive_parameters_0 = false;
			break;
			case 1:
			alive_parameters_0 = false;
			alive_parameters_1 = false;
			break;
		}
		switch(MOP_lastevent) {
			case -1:
			return;
			case 0:
			//create
			//alive_c && alive_i
			if(!(alive_parameters_0)){
				MOP_terminated = true;
				return;
			}
			break;

			case 1:
			//updatesource
			//alive_i
			if(!(alive_parameters_1)){
				MOP_terminated = true;
				return;
			}
			break;

			case 2:
			//next
			//alive_c && alive_i
			if(!(alive_parameters_0)){
				MOP_terminated = true;
				return;
			}
			break;

		}
		return;
	}

}

public aspect UnsafeIteratorMonitorAspect implements javamoprt.MOPObject {
	javamoprt.map.MOPMapManager UnsafeIteratorMapManager;
	public UnsafeIteratorMonitorAspect(){
		UnsafeIteratorMapManager = new javamoprt.map.MOPMapManager();
		UnsafeIteratorMapManager.start();
	}

	// Declarations for the Lock
	static ReentrantLock UnsafeIterator_MOPLock = new ReentrantLock();
	static Condition UnsafeIterator_MOPLock_cond = UnsafeIterator_MOPLock.newCondition();

	// Declarations for Timestamps
	static long UnsafeIterator_timestamp = 1;

	static boolean UnsafeIterator_activated = false;

	// Declarations for Indexing Trees
	static javamoprt.ref.MOPTagWeakReference UnsafeIterator_c_Map_cachekey_0 = javamoprt.map.MOPTagRefMap.NULRef;
	static UnsafeIteratorMonitor_Set UnsafeIterator_c_Map_cacheset = null;
	static UnsafeIteratorMonitor UnsafeIterator_c_Map_cachenode = null;
	static javamoprt.map.MOPAbstractMap UnsafeIterator_c_i_Map = new javamoprt.map.MOPMapOfAll(0);
	static javamoprt.ref.MOPTagWeakReference UnsafeIterator_c_i_Map_cachekey_0 = javamoprt.map.MOPTagRefMap.NULRef;
	static javamoprt.ref.MOPTagWeakReference UnsafeIterator_c_i_Map_cachekey_1 = javamoprt.map.MOPTagRefMap.NULRef;
	static UnsafeIteratorMonitor UnsafeIterator_c_i_Map_cachenode = null;
	static javamoprt.map.MOPAbstractMap UnsafeIterator_i_Map = new javamoprt.map.MOPMapOfSetMon(1);
	static javamoprt.ref.MOPTagWeakReference UnsafeIterator_i_Map_cachekey_1 = javamoprt.map.MOPTagRefMap.NULRef;
	static UnsafeIteratorMonitor_Set UnsafeIterator_i_Map_cacheset = null;
	static UnsafeIteratorMonitor UnsafeIterator_i_Map_cachenode = null;

	// Trees for References
	static javamoprt.map.MOPRefMap UnsafeIterator_Collection_RefMap = new javamoprt.map.MOPTagRefMap();
	static javamoprt.map.MOPRefMap UnsafeIterator_Iterator_RefMap = new javamoprt.map.MOPTagRefMap();

	pointcut MOP_CommonPointCut() : !within(javamoprt.MOPObject+) && !adviceexecution();
	pointcut UnsafeIterator_create(Collection c) : (call(Iterator Collection+.iterator()) && target(c)) && MOP_CommonPointCut();
	after (Collection c) returning (Iterator i) : UnsafeIterator_create(c) {
		UnsafeIterator_activated = true;
		while (!UnsafeIterator_MOPLock.tryLock()) {
			Thread.yield();
		}
		Object obj;
		javamoprt.map.MOPMap tempMap;
		UnsafeIteratorMonitor mainMonitor = null;
		javamoprt.map.MOPMap mainMap = null;
		UnsafeIteratorMonitor_Set monitors = null;
		javamoprt.ref.MOPTagWeakReference TempRef_c;
		javamoprt.ref.MOPTagWeakReference TempRef_i;

		// Cache Retrieval
		if (c == UnsafeIterator_c_i_Map_cachekey_0.get() && i == UnsafeIterator_c_i_Map_cachekey_1.get()) {
			TempRef_c = UnsafeIterator_c_i_Map_cachekey_0;
			TempRef_i = UnsafeIterator_c_i_Map_cachekey_1;

			mainMonitor = UnsafeIterator_c_i_Map_cachenode;
		} else {
			TempRef_c = UnsafeIterator_Collection_RefMap.getTagRef(c);
			TempRef_i = UnsafeIterator_Iterator_RefMap.getTagRef(i);
		}

		if (mainMonitor == null) {
			tempMap = UnsafeIterator_c_i_Map;
			obj = tempMap.getMap(TempRef_c);
			if (obj == null) {
				obj = new javamoprt.map.MOPMapOfMonitor(1);
				tempMap.putMap(TempRef_c, obj);
			}
			mainMap = (javamoprt.map.MOPAbstractMap)obj;
			mainMonitor = (UnsafeIteratorMonitor)mainMap.getNode(TempRef_i);

			if (mainMonitor == null) {
				mainMonitor = new UnsafeIteratorMonitor();

				mainMonitor.MOPRef_c = TempRef_c;
				mainMonitor.MOPRef_i = TempRef_i;

				mainMap.putNode(TempRef_i, mainMonitor);
				mainMonitor.tau = UnsafeIterator_timestamp;
				if (TempRef_c.tau == -1){
					TempRef_c.tau = UnsafeIterator_timestamp;
				}
				if (TempRef_i.tau == -1){
					TempRef_i.tau = UnsafeIterator_timestamp;
				}
				UnsafeIterator_timestamp++;

				tempMap = UnsafeIterator_c_i_Map;
				obj = tempMap.getSet(TempRef_c);
				monitors = (UnsafeIteratorMonitor_Set)obj;
				if (monitors == null) {
					monitors = new UnsafeIteratorMonitor_Set();
					tempMap.putSet(TempRef_c, monitors);
				}
				monitors.add(mainMonitor);

				tempMap = UnsafeIterator_i_Map;
				obj = tempMap.getSet(TempRef_i);
				monitors = (UnsafeIteratorMonitor_Set)obj;
				if (monitors == null) {
					monitors = new UnsafeIteratorMonitor_Set();
					tempMap.putSet(TempRef_i, monitors);
				}
				monitors.add(mainMonitor);
			}

			UnsafeIterator_c_i_Map_cachekey_0 = TempRef_c;
			UnsafeIterator_c_i_Map_cachekey_1 = TempRef_i;
			UnsafeIterator_c_i_Map_cachenode = mainMonitor;
		}

		mainMonitor.Prop_1_event_create(c, i);
		if(mainMonitor.Prop_1_Category_match) {
			mainMonitor.Prop_1_handler_match(c, i);
		}
		UnsafeIterator_MOPLock.unlock();
	}

	pointcut UnsafeIterator_updatesource(Collection c) : ((call(* Collection+.remove*(..)) || call(* Collection+.add*(..))) && target(c)) && MOP_CommonPointCut();
	after (Collection c) : UnsafeIterator_updatesource(c) {
		UnsafeIterator_activated = true;
		while (!UnsafeIterator_MOPLock.tryLock()) {
			Thread.yield();
		}
		UnsafeIteratorMonitor mainMonitor = null;
		javamoprt.map.MOPMap mainMap = null;
		UnsafeIteratorMonitor_Set mainSet = null;
		javamoprt.ref.MOPTagWeakReference TempRef_c;

		// Cache Retrieval
		if (c == UnsafeIterator_c_Map_cachekey_0.get()) {
			TempRef_c = UnsafeIterator_c_Map_cachekey_0;

			mainSet = UnsafeIterator_c_Map_cacheset;
			mainMonitor = UnsafeIterator_c_Map_cachenode;
		} else {
			TempRef_c = UnsafeIterator_Collection_RefMap.getTagRef(c);
		}

		if (mainSet == null || mainMonitor == null) {
			mainMap = UnsafeIterator_c_i_Map;
			mainMonitor = (UnsafeIteratorMonitor)mainMap.getNode(TempRef_c);
			mainSet = (UnsafeIteratorMonitor_Set)mainMap.getSet(TempRef_c);
			if (mainSet == null){
				mainSet = new UnsafeIteratorMonitor_Set();
				mainMap.putSet(TempRef_c, mainSet);
			}

			if (mainMonitor == null) {
				mainMonitor = new UnsafeIteratorMonitor();

				mainMonitor.MOPRef_c = TempRef_c;

				UnsafeIterator_c_i_Map.putNode(TempRef_c, mainMonitor);
				mainSet.add(mainMonitor);
				mainMonitor.tau = UnsafeIterator_timestamp;
				if (TempRef_c.tau == -1){
					TempRef_c.tau = UnsafeIterator_timestamp;
				}
				UnsafeIterator_timestamp++;
			}

			UnsafeIterator_c_Map_cachekey_0 = TempRef_c;
			UnsafeIterator_c_Map_cacheset = mainSet;
			UnsafeIterator_c_Map_cachenode = mainMonitor;
		}

		if(mainSet != null) {
			mainSet.event_updatesource(c);
		}
		UnsafeIterator_MOPLock.unlock();
	}

	pointcut UnsafeIterator_next(Iterator i) : (call(* Iterator.next()) && target(i)) && MOP_CommonPointCut();
	before (Iterator i) : UnsafeIterator_next(i) {
		UnsafeIterator_activated = true;
		while (!UnsafeIterator_MOPLock.tryLock()) {
			Thread.yield();
		}
		UnsafeIteratorMonitor mainMonitor = null;
		javamoprt.map.MOPMap mainMap = null;
		UnsafeIteratorMonitor_Set mainSet = null;
		javamoprt.ref.MOPTagWeakReference TempRef_i;

		// Cache Retrieval
		if (i == UnsafeIterator_i_Map_cachekey_1.get()) {
			TempRef_i = UnsafeIterator_i_Map_cachekey_1;

			mainSet = UnsafeIterator_i_Map_cacheset;
			mainMonitor = UnsafeIterator_i_Map_cachenode;
		} else {
			TempRef_i = UnsafeIterator_Iterator_RefMap.getTagRef(i);
		}

		if (mainSet == null || mainMonitor == null) {
			mainMap = UnsafeIterator_i_Map;
			mainMonitor = (UnsafeIteratorMonitor)mainMap.getNode(TempRef_i);
			mainSet = (UnsafeIteratorMonitor_Set)mainMap.getSet(TempRef_i);
			if (mainSet == null){
				mainSet = new UnsafeIteratorMonitor_Set();
				mainMap.putSet(TempRef_i, mainSet);
			}

			if (mainMonitor == null) {
				mainMonitor = new UnsafeIteratorMonitor();

				mainMonitor.MOPRef_i = TempRef_i;

				UnsafeIterator_i_Map.putNode(TempRef_i, mainMonitor);
				mainSet.add(mainMonitor);
				mainMonitor.tau = UnsafeIterator_timestamp;
				if (TempRef_i.tau == -1){
					TempRef_i.tau = UnsafeIterator_timestamp;
				}
				UnsafeIterator_timestamp++;
			}

			UnsafeIterator_i_Map_cachekey_1 = TempRef_i;
			UnsafeIterator_i_Map_cacheset = mainSet;
			UnsafeIterator_i_Map_cachenode = mainMonitor;
		}

		if(mainSet != null) {
			mainSet.event_next(i);
		}
		UnsafeIterator_MOPLock.unlock();
	}

}
