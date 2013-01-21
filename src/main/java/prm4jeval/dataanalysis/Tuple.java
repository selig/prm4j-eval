/*
 * Copyright (c) 2012 Mateusz Parzonka, Eric Bodden
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Mateusz Parzonka - initial API and implementation
 */
package prm4jeval.dataanalysis;

public class Tuple<T1, T2> {

    private final T1 left;
    private final T2 right;

    public Tuple(T1 left, T2 right) {
	super();
	this.left = left;
	this.right = right;
    }

    public static <T1, T2> Tuple<T1, T2> tuple(T1 _1, T2 _2) {
	return new Tuple<T1, T2>(_1, _2);
    }

    public T1 _1() {
	return left;
    }

    public T2 _2() {
	return right;
    }

    @Override
    public int hashCode() {
	final int prime = 31;
	int result = 1;
	result = prime * result + ((left == null) ? 0 : left.hashCode());
	result = prime * result + ((right == null) ? 0 : right.hashCode());
	return result;
    }

    @SuppressWarnings("rawtypes")
    @Override
    public boolean equals(Object obj) {
	if (this == obj)
	    return true;
	if (obj == null)
	    return false;
	if (getClass() != obj.getClass())
	    return false;
	Tuple other = (Tuple) obj;
	if (left == null) {
	    if (other.left != null)
		return false;
	} else if (!left.equals(other.left))
	    return false;
	if (right == null) {
	    if (other.right != null)
		return false;
	} else if (!right.equals(other.right))
	    return false;
	return true;
    }

    @Override
    public String toString() {
	return "(" + left + ", " + right + ")";
    }

}
