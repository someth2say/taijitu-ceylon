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

shared interface Comparator<T> satisfies JComparator<T> & Equalizer<T> {}

//shared interface ComparatorHasher<T> satisfies Comparator<T> & Hasher<T> {}
