shared abstract class AbstractConfigurableEqualizer<T, CONFIG=Null> satisfies Equalizer<T> {
	import ceylon.language.meta {
		type
	}
	
	shared CONFIG equalityConfig;
	
	shared new (CONFIG equalityConfig) {
		this.equalityConfig = equalityConfig;
	}
	
	shared actual {Difference<Anything>*}? underlyingDiffs(T t1, T t2) {
		Difference<Anything> ue = Unequal<Anything>.withoutUnderlying(this, t1, t2);
		return if (areEquals(t1, t2)) then null else { ue };
	}
	
	string => "``className(type(this))``[`` equalityConfig?.string else "" ``]";
	
	hash => [type(this), equalityConfig].fold(1)((i, element) => 31*i + (element?.hash else 0));
	
	shared actual default Boolean equals(Object o) {
		if (this == o) { return true; }
		if (is AbstractConfigurableEqualizer<T,CONFIG> o) {
			value sameConfig = if (exists equalityConfig) then if (exists otherconfig = o.equalityConfig) then equalityConfig.equals(otherconfig) else false else (o.equalityConfig exists);
			value sameType = type(this).equals(type(o));
			return sameType && sameConfig;
		} else {
			return false;
		}
	}
}

shared class DateThreshold<T> extends AbstractConfigurableEqualizer<T,Integer> satisfies Comparator<T> given T satisfies Date {
	
	import java.util {
		Date
	}
	
	static
	Integer defaultThreshold = 1000;
	Integer threshold;
	
	shared new default() extends AbstractConfigurableEqualizer<T,Integer>(defaultThreshold) {
		threshold = defaultThreshold;
	}
	
	shared new (Integer equalityConfig) extends AbstractConfigurableEqualizer<T,Integer>(if (is Integer parse = Integer.parse(equalityConfig.string)) then parse else defaultThreshold) {}
	
	shared actual Boolean areEquals(T object1, T object2) => (Integer.magnitude(object1.time - object2.time) < equalityConfig);
	
	shared actual Integer compare(T object1, T object2) {
		Integer diff = object1.time - object2.time;
		return if (Integer.magnitude(diff) < equalityConfig) then 0 else if (diff < 0) then -1 else 1;
	}
	
	equals(Object o) => (this of AbstractConfigurableEqualizer<T,Integer>).equals(o);
}

shared class JavaComparable<T> extends AbstractConfigurableEqualizer<T> satisfies Comparator<T> & Hasher<T> given T satisfies JComparable<T> {
	import java.lang {
		JComparable=Comparable
	}
	
	shared new () extends AbstractConfigurableEqualizer<T>(null) {}
	
	shared actual Integer compare(T first, T second) => first.compareTo(second);
	
	equals(Object o) => (this of AbstractConfigurableEqualizer<T>).equals(o);
}

shared class CeylonComparable<T> extends AbstractConfigurableEqualizer<T> satisfies Comparator<T> & Hasher<T> given T satisfies CComparable<T> {
	import ceylon.language {
		CComparable=Comparable
	}
	
	shared new () extends AbstractConfigurableEqualizer<T>(null) {}
	
	shared actual Integer compare(T first, T second) => switch (first.compare(second)) case (larger) 1 case (smaller) -1 case (equal) 0;
	
	equals(Object o) => (this of AbstractConfigurableEqualizer<T>).equals(o);
}
