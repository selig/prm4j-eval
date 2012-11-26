package mop;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.locks.*;
import javamoprt.*;
import java.lang.ref.*;
import org.aspectj.lang.*;

class SafeIteratorMonitor_Set extends javamoprt.MOPSet {
	protected SafeIteratorMonitor[] elementData;

	public SafeIteratorMonitor_Set(){
		this.size = 0;
		this.elementData = new SafeIteratorMonitor[4];
	}

	public final int size(){
		while(size > 0 && elementData[size-1].MOP_terminated) {
			elementData[--size] = null;
		}
		return size;
	}

	public final boolean add(MOPMonitor e){
		ensureCapacity();
		elementData[size++] = (SafeIteratorMonitor)e;
		return true;
	}

	public final void endObject(int idnum){
		int numAlive = 0;
		for(int i = 0; i < size; i++){
			SafeIteratorMonitor monitor = elementData[i];
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
			SafeIteratorMonitor[] oldData = elementData;
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
			SafeIteratorMonitor monitor = (SafeIteratorMonitor)elementData[i];
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
			SafeIteratorMonitor monitor = (SafeIteratorMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_create(c, i);
				if(monitor.Prop_1_Category_violation) {
					monitor.Prop_1_handler_violation(c, i);
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
			SafeIteratorMonitor monitor = (SafeIteratorMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_updatesource(c);
				if(monitor.Prop_1_Category_violation) {
					monitor.Prop_1_handler_violation(c, null);
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
			SafeIteratorMonitor monitor = (SafeIteratorMonitor)this.elementData[i_1];
			if(!monitor.MOP_terminated){
				elementData[numAlive] = monitor;
				numAlive++;

				monitor.Prop_1_event_next(i);
				if(monitor.Prop_1_Category_violation) {
					monitor.Prop_1_handler_violation(null, i);
				}
			}
		}
		for(int i_1 = numAlive; i_1 < this.size; i_1++){
			this.elementData[i_1] = null;
		}
		size = numAlive;
	}
}

class SafeIteratorMonitor extends javamoprt.MOPMonitor implements Cloneable, javamoprt.MOPObject {
	public long tau = -1;
	public Object clone() {
		try {
			SafeIteratorMonitor ret = (SafeIteratorMonitor) super.clone();
			ret.monitorInfo = (javamoprt.MOPMonitorInfo)this.monitorInfo.clone();
			return ret;
		}
		catch (CloneNotSupportedException e) {
			throw new InternalError(e.toString());
		}
	}

	int Prop_1_state;
	static final int Prop_1_transition_create[] = {2, 3, 2, 3};;
	static final int Prop_1_transition_updatesource[] = {0, 3, 0, 3};;
	static final int Prop_1_transition_next[] = {1, 3, 2, 3};;

	boolean Prop_1_Category_violation = false;

	public SafeIteratorMonitor () {
		Prop_1_state = 0;

	}

	public final void Prop_1_event_create(Collection c, Iterator i) {
		MOP_lastevent = 0;

		Prop_1_state = Prop_1_transition_create[Prop_1_state];
		if(this.monitorInfo.isFullParam){
			Prop_1_Category_violation = Prop_1_state == 1;
		}
	}

	public final void Prop_1_event_updatesource(Collection c) {
		MOP_lastevent = 1;

		Prop_1_state = Prop_1_transition_updatesource[Prop_1_state];
		if(this.monitorInfo.isFullParam){
			Prop_1_Category_violation = Prop_1_state == 1;
		}
	}

	public final void Prop_1_event_next(Iterator i) {
		MOP_lastevent = 2;

		Prop_1_state = Prop_1_transition_next[Prop_1_state];
		if(this.monitorInfo.isFullParam){
			Prop_1_Category_violation = Prop_1_state == 1;
		}
	}

	public final void Prop_1_handler_violation (Collection c, Iterator i){
		{
			System.out.println("improper iterator usage");
		}

	}

	public final void reset() {
		MOP_lastevent = -1;
		Prop_1_state = 0;
		Prop_1_Category_violation = false;
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

	javamoprt.MOPMonitorInfo monitorInfo;
}

public aspect SafeIteratorMonitorAspect implements javamoprt.MOPObject {
	javamoprt.map.MOPMapManager SafeIteratorMapManager;
	public SafeIteratorMonitorAspect(){
		SafeIteratorMapManager = new javamoprt.map.MOPMapManager();
		SafeIteratorMapManager.start();
	}

	// Declarations for the Lock
	static ReentrantLock SafeIterator_MOPLock = new ReentrantLock();
	static Condition SafeIterator_MOPLock_cond = SafeIterator_MOPLock.newCondition();

	// Declarations for Timestamps
	static long SafeIterator_timestamp = 1;

	static boolean SafeIterator_activated = false;

	// Declarations for Indexing Trees
	static javamoprt.ref.MOPTagWeakReference SafeIterator_c_Map_cachekey_0 = javamoprt.map.MOPTagRefMap.NULRef;
	static SafeIteratorMonitor_Set SafeIterator_c_Map_cacheset = null;
	static SafeIteratorMonitor SafeIterator_c_Map_cachenode = null;
	static javamoprt.map.MOPAbstractMap SafeIterator_c_i_Map = new javamoprt.map.MOPMapOfAll(0);
	static javamoprt.ref.MOPTagWeakReference SafeIterator_c_i_Map_cachekey_0 = javamoprt.map.MOPTagRefMap.NULRef;
	static javamoprt.ref.MOPTagWeakReference SafeIterator_c_i_Map_cachekey_1 = javamoprt.map.MOPTagRefMap.NULRef;
	static SafeIteratorMonitor SafeIterator_c_i_Map_cachenode = null;
	static javamoprt.map.MOPAbstractMap SafeIterator_i_Map = new javamoprt.map.MOPMapOfSetMon(1);
	static javamoprt.ref.MOPTagWeakReference SafeIterator_i_Map_cachekey_1 = javamoprt.map.MOPTagRefMap.NULRef;
	static SafeIteratorMonitor_Set SafeIterator_i_Map_cacheset = null;
	static SafeIteratorMonitor SafeIterator_i_Map_cachenode = null;
	static SafeIteratorMonitor_Set SafeIterator__To__c_Set = new SafeIteratorMonitor_Set();

	// Trees for References
	static javamoprt.map.MOPRefMap SafeIterator_Collection_RefMap = new javamoprt.map.MOPTagRefMap();
	static javamoprt.map.MOPRefMap SafeIterator_Iterator_RefMap = new javamoprt.map.MOPTagRefMap();

	pointcut MOP_CommonPointCut() : !within(javamoprt.MOPObject+) && !adviceexecution();
	pointcut SafeIterator_create(Collection c) : (call(Iterator Collection+.iterator()) && target(c)) && MOP_CommonPointCut();
	after (Collection c) returning (Iterator i) : SafeIterator_create(c) {
		SafeIterator_activated = true;
		while (!SafeIterator_MOPLock.tryLock()) {
			Thread.yield();
		}
		Object obj;
		javamoprt.map.MOPMap tempMap;
		SafeIteratorMonitor mainMonitor = null;
		SafeIteratorMonitor origMonitor = null;
		javamoprt.map.MOPMap mainMap = null;
		javamoprt.map.MOPMap origMap = null;
		SafeIteratorMonitor_Set monitors = null;
		javamoprt.ref.MOPTagWeakReference TempRef_c;
		javamoprt.ref.MOPTagWeakReference TempRef_i;

		// Cache Retrieval
		if (c == SafeIterator_c_i_Map_cachekey_0.get() && i == SafeIterator_c_i_Map_cachekey_1.get()) {
			TempRef_c = SafeIterator_c_i_Map_cachekey_0;
			TempRef_i = SafeIterator_c_i_Map_cachekey_1;

			mainMonitor = SafeIterator_c_i_Map_cachenode;
		} else {
			TempRef_c = SafeIterator_Collection_RefMap.getTagRef(c);
			TempRef_i = SafeIterator_Iterator_RefMap.getTagRef(i);
		}

		if (mainMonitor == null) {
			tempMap = SafeIterator_c_i_Map;
			obj = tempMap.getMap(TempRef_c);
			if (obj == null) {
				obj = new javamoprt.map.MOPMapOfMonitor(1);
				tempMap.putMap(TempRef_c, obj);
			}
			mainMap = (javamoprt.map.MOPAbstractMap)obj;
			mainMonitor = (SafeIteratorMonitor)mainMap.getNode(TempRef_i);

			if (mainMonitor == null) {
				if (mainMonitor == null) {
					origMap = SafeIterator_c_i_Map;
					origMonitor = (SafeIteratorMonitor)origMap.getNode(TempRef_c);
					if (origMonitor != null) {
						boolean timeCheck = true;

						if (TempRef_i.disable > origMonitor.tau) {
							timeCheck = false;
						}

						if (timeCheck) {
							mainMonitor = (SafeIteratorMonitor)origMonitor.clone();
							mainMonitor.MOPRef_i = TempRef_i;
							if (TempRef_i.tau == -1){
								TempRef_i.tau = origMonitor.tau;
							}
							mainMap.putNode(TempRef_i, mainMonitor);
							mainMonitor.monitorInfo.isFullParam = true;

							tempMap = SafeIterator_c_i_Map;
							obj = tempMap.getSet(TempRef_c);
							monitors = (SafeIteratorMonitor_Set)obj;
							if (monitors == null) {
								monitors = new SafeIteratorMonitor_Set();
								tempMap.putSet(TempRef_c, monitors);
							}
							monitors.add(mainMonitor);

							tempMap = SafeIterator_i_Map;
							obj = tempMap.getSet(TempRef_i);
							monitors = (SafeIteratorMonitor_Set)obj;
							if (monitors == null) {
								monitors = new SafeIteratorMonitor_Set();
								tempMap.putSet(TempRef_i, monitors);
							}
							monitors.add(mainMonitor);
						}
					}
				}
				if (mainMonitor == null) {
					mainMonitor = new SafeIteratorMonitor();
					mainMonitor.monitorInfo = new javamoprt.MOPMonitorInfo();
					mainMonitor.monitorInfo.isFullParam = true;

					mainMonitor.MOPRef_c = TempRef_c;
					mainMonitor.MOPRef_i = TempRef_i;

					mainMap.putNode(TempRef_i, mainMonitor);
					mainMonitor.tau = SafeIterator_timestamp;
					if (TempRef_c.tau == -1){
						TempRef_c.tau = SafeIterator_timestamp;
					}
					if (TempRef_i.tau == -1){
						TempRef_i.tau = SafeIterator_timestamp;
					}
					SafeIterator_timestamp++;

					tempMap = SafeIterator_c_i_Map;
					obj = tempMap.getSet(TempRef_c);
					monitors = (SafeIteratorMonitor_Set)obj;
					if (monitors == null) {
						monitors = new SafeIteratorMonitor_Set();
						tempMap.putSet(TempRef_c, monitors);
					}
					monitors.add(mainMonitor);

					tempMap = SafeIterator_i_Map;
					obj = tempMap.getSet(TempRef_i);
					monitors = (SafeIteratorMonitor_Set)obj;
					if (monitors == null) {
						monitors = new SafeIteratorMonitor_Set();
						tempMap.putSet(TempRef_i, monitors);
					}
					monitors.add(mainMonitor);
				}

				TempRef_i.disable = SafeIterator_timestamp;
				SafeIterator_timestamp++;
			}

			SafeIterator_c_i_Map_cachekey_0 = TempRef_c;
			SafeIterator_c_i_Map_cachekey_1 = TempRef_i;
			SafeIterator_c_i_Map_cachenode = mainMonitor;
		}

		mainMonitor.Prop_1_event_create(c, i);
		if(mainMonitor.Prop_1_Category_violation) {
			mainMonitor.Prop_1_handler_violation(c, i);
		}
		SafeIterator_MOPLock.unlock();
	}

	pointcut SafeIterator_updatesource(Collection c) : ((call(* Collection+.remove*(..)) || call(* Collection+.add*(..))) && target(c)) && MOP_CommonPointCut();
	after (Collection c) : SafeIterator_updatesource(c) {
		SafeIterator_activated = true;
		while (!SafeIterator_MOPLock.tryLock()) {
			Thread.yield();
		}
		SafeIteratorMonitor mainMonitor = null;
		javamoprt.map.MOPMap mainMap = null;
		SafeIteratorMonitor_Set mainSet = null;
		javamoprt.ref.MOPTagWeakReference TempRef_c;

		// Cache Retrieval
		if (c == SafeIterator_c_Map_cachekey_0.get()) {
			TempRef_c = SafeIterator_c_Map_cachekey_0;

			mainSet = SafeIterator_c_Map_cacheset;
			mainMonitor = SafeIterator_c_Map_cachenode;
		} else {
			TempRef_c = SafeIterator_Collection_RefMap.getTagRef(c);
		}

		if (mainSet == null || mainMonitor == null) {
			mainMap = SafeIterator_c_i_Map;
			mainMonitor = (SafeIteratorMonitor)mainMap.getNode(TempRef_c);
			mainSet = (SafeIteratorMonitor_Set)mainMap.getSet(TempRef_c);
			if (mainSet == null){
				mainSet = new SafeIteratorMonitor_Set();
				mainMap.putSet(TempRef_c, mainSet);
			}

			if (mainMonitor == null) {
				mainMonitor = new SafeIteratorMonitor();
				mainMonitor.monitorInfo = new javamoprt.MOPMonitorInfo();
				mainMonitor.monitorInfo.isFullParam = false;

				mainMonitor.MOPRef_c = TempRef_c;

				SafeIterator_c_i_Map.putNode(TempRef_c, mainMonitor);
				mainSet.add(mainMonitor);
				mainMonitor.tau = SafeIterator_timestamp;
				if (TempRef_c.tau == -1){
					TempRef_c.tau = SafeIterator_timestamp;
				}
				SafeIterator_timestamp++;

				SafeIterator__To__c_Set.add(mainMonitor);
			}

			SafeIterator_c_Map_cachekey_0 = TempRef_c;
			SafeIterator_c_Map_cacheset = mainSet;
			SafeIterator_c_Map_cachenode = mainMonitor;
		}

		if(mainSet != null) {
			mainSet.event_updatesource(c);
		}
		SafeIterator_MOPLock.unlock();
	}

	pointcut SafeIterator_next(Iterator i) : (call(* Iterator.next()) && target(i)) && MOP_CommonPointCut();
	before (Iterator i) : SafeIterator_next(i) {
		SafeIterator_activated = true;
		while (!SafeIterator_MOPLock.tryLock()) {
			Thread.yield();
		}
		Object obj;
		javamoprt.map.MOPMap tempMap;
		SafeIteratorMonitor mainMonitor = null;
		SafeIteratorMonitor origMonitor = null;
		SafeIteratorMonitor lastMonitor = null;
		javamoprt.map.MOPMap mainMap = null;
		javamoprt.map.MOPMap lastMap = null;
		SafeIteratorMonitor_Set mainSet = null;
		SafeIteratorMonitor_Set origSet = null;
		SafeIteratorMonitor_Set monitors = null;
		javamoprt.ref.MOPTagWeakReference TempRef_c;
		javamoprt.ref.MOPTagWeakReference TempRef_i;

		// Cache Retrieval
		if (i == SafeIterator_i_Map_cachekey_1.get()) {
			TempRef_i = SafeIterator_i_Map_cachekey_1;

			mainSet = SafeIterator_i_Map_cacheset;
			mainMonitor = SafeIterator_i_Map_cachenode;
		} else {
			TempRef_i = SafeIterator_Iterator_RefMap.getTagRef(i);
		}

		if (mainSet == null || mainMonitor == null) {
			mainMap = SafeIterator_i_Map;
			mainMonitor = (SafeIteratorMonitor)mainMap.getNode(TempRef_i);
			mainSet = (SafeIteratorMonitor_Set)mainMap.getSet(TempRef_i);
			if (mainSet == null){
				mainSet = new SafeIteratorMonitor_Set();
				mainMap.putSet(TempRef_i, mainSet);
			}

			if (mainMonitor == null) {
				origSet = SafeIterator__To__c_Set;
				if (origSet!= null) {
					int numAlive = 0;
					for(int i_1 = 0; i_1 < origSet.size; i_1++) {
						origMonitor = origSet.elementData[i_1];
						Collection c = (Collection)origMonitor.MOPRef_c.get();
						if (!origMonitor.MOP_terminated && c != null) {
							origSet.elementData[numAlive] = origMonitor;
							numAlive++;

							TempRef_c = origMonitor.MOPRef_c;

							tempMap = SafeIterator_c_i_Map;
							obj = tempMap.getMap(TempRef_c);
							if (obj == null) {
								obj = new javamoprt.map.MOPMapOfMonitor(1);
								tempMap.putMap(TempRef_c, obj);
							}
							lastMap = (javamoprt.map.MOPAbstractMap)obj;
							lastMonitor = (SafeIteratorMonitor)lastMap.getNode(TempRef_i);
							if (lastMonitor == null) {
								boolean timeCheck = true;

								if (TempRef_i.disable > origMonitor.tau|| (TempRef_i.tau > 0 && TempRef_i.tau < origMonitor.tau)) {
									timeCheck = false;
								}

								if (timeCheck) {
									lastMonitor = (SafeIteratorMonitor)origMonitor.clone();
									lastMonitor.MOPRef_i = TempRef_i;
									if (TempRef_i.tau == -1){
										TempRef_i.tau = origMonitor.tau;
									}
									lastMap.putNode(TempRef_i, lastMonitor);
									lastMonitor.monitorInfo.isFullParam = true;

									tempMap = SafeIterator_c_i_Map;
									obj = tempMap.getSet(TempRef_c);
									monitors = (SafeIteratorMonitor_Set)obj;
									if (monitors == null) {
										monitors = new SafeIteratorMonitor_Set();
										tempMap.putSet(TempRef_c, monitors);
									}
									monitors.add(lastMonitor);

									mainMap = SafeIterator_i_Map;
									obj = mainMap.getSet(TempRef_i);
									mainSet = (SafeIteratorMonitor_Set)obj;
									if (mainSet == null) {
										mainSet = new SafeIteratorMonitor_Set();
										mainMap.putSet(TempRef_i, mainSet);
									}
									mainSet.add(lastMonitor);
								}
							}
						}
					}

					for(int i_1 = numAlive; i_1 < origSet.size; i_1++) {
						origSet.elementData[i_1] = null;
					}
					origSet.size = numAlive;
				}
				if (mainMonitor == null) {
					mainMonitor = new SafeIteratorMonitor();
					mainMonitor.monitorInfo = new javamoprt.MOPMonitorInfo();
					mainMonitor.monitorInfo.isFullParam = false;

					mainMonitor.MOPRef_i = TempRef_i;

					SafeIterator_i_Map.putNode(TempRef_i, mainMonitor);
					mainSet.add(mainMonitor);
					mainMonitor.tau = SafeIterator_timestamp;
					if (TempRef_i.tau == -1){
						TempRef_i.tau = SafeIterator_timestamp;
					}
					SafeIterator_timestamp++;
				}

				TempRef_i.disable = SafeIterator_timestamp;
				SafeIterator_timestamp++;
			}

			SafeIterator_i_Map_cachekey_1 = TempRef_i;
			SafeIterator_i_Map_cacheset = mainSet;
			SafeIterator_i_Map_cachenode = mainMonitor;
		}

		if(mainSet != null) {
			mainSet.event_next(i);
		}
		SafeIterator_MOPLock.unlock();
	}

}
