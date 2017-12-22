import java.lang {
	JComparable=Comparable
}

import java.util {
	JComparator=Comparator
}

import ceylon.language {
	CComparable=Comparable
}

/**
 Internal aspects: Objects that define equality and (maybe) its contracts
 */
shared interface Equalizable<T> {
	shared formal actual Boolean equals(Object other);
	shared formal Boolean equalsTo(T other);
}

shared interface Hashable<T> satisfies Equalizable<T> {
	shared formal actual Integer hash;
}

shared interface Comparable<T> of T satisfies CComparable<T> & JComparable<T> given T satisfies Comparable<T> {}


/**
 External aspects: Objects that can apply equality and (maybe) its contracts to other objects.
 */

shared interface Equalizer<T> {
	
	shared formal {Difference<Anything>*}? underlyingDiffs(T t1, T t2);

	shared default Boolean areEquals(T t1, T t2) => underlyingDiffs(t1, t2)?.empty else false;	
	
	shared default Unequal<T>? asUnequal(T t1, T t2) => if (exists diffs = underlyingDiffs(t1, t2)) then if (!diffs.empty) then Unequal(this, t1, t2, diffs) else null else null;
	
	shared default Missing<T> asMissing(T t1) => Missing(this, t1);
}

shared interface Hasher<T> satisfies Equalizer<T> {
	shared default Integer hashCode(T t) => if (exists t) then t.hash else 0;
}

shared interface Comparator<T> satisfies JComparator<T> & Equalizer<T> {
 // Java comparator defines "compare(a,b)".	 
	shared formal actual Integer compare(T? first, T? second);	
 // But Ceylon defines no "Comparator" interface, only "Comparable". So we should add the sibiling methods here:
 //Problem: compare(T,T) is defined in both interfaces but with different results! Should rename...
	shared formal Comparison compareTo(T first, T second);
	shared formal Boolean largerThan(T first, T second);
	shared formal Boolean smallerThan(T first, T second);
	shared formal Boolean notSmallerThan(T first, T second);
	shared formal Boolean notLargerThan(T first, T second); 
}

//shared interface ComparatorHasher<T> satisfies Comparator<T> & Hasher<T> {}
