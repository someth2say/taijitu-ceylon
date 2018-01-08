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
	
	areEquals(T first, T second) => (Integer.magnitude(first.time - second.time) < equalityConfig);
	
	function _compare(T first, T second) {
		Integer diff = first.time - second.time;
		return if (Integer.magnitude(diff) < equalityConfig) then 0 else if (diff < 0) then -1 else 1;
	}
	
	compare(T? first, T? second) =>
		if (exists first, exists second) then _compare(first, second)
		else if ((first exists) == (second exists)) then 0
			else if ((first exists)) then 1
				else -1;
	
	compareTo(T first, T second) => let (cmp = _compare(first, second)) if (cmp == 0) then equal else if (cmp < 0) then smaller else larger;
	
	equals(Object other) => (this of AbstractConfigurableEqualizer<T,Integer>).equals(other);
}

shared class JavaComparable<T> extends AbstractConfigurableEqualizer<T> satisfies Comparator<T> & Hasher<T> given T satisfies JComparable<T> {
	import java.lang {
		JComparable=Comparable
	}
	
	shared new () extends AbstractConfigurableEqualizer<T>(null) {}
	
	compare(T? first, T? second) =>
		if (exists first, exists second) then first.compareTo(second)
		else if ((first exists) == (second exists)) then 0
			else if ((first exists)) then 1
				else -1;
	
	compareTo(T first, T second) => let (cmp = first.compareTo(second)) if (cmp == 0) then equal else if (cmp < 0) then smaller else larger;
	
	equals(Object other) => (this of AbstractConfigurableEqualizer<T>).equals(other);
}

shared class CeylonComparable<T> extends AbstractConfigurableEqualizer<T> satisfies Comparator<T> & Hasher<T> given T satisfies CComparable<T> {
	import ceylon.language {
		CComparable=Comparable
	}
	
	shared new default() extends AbstractConfigurableEqualizer<T>(null) {}
	
	compare(T? first, T? second) =>
		if (exists first, exists second) then (switch (first.compare(second)) case (larger) 1 case (smaller) -1 else 0)
		else if ((first exists) == (second exists)) then 0
			else if ((first exists)) then 1
				else -1;
	
	equals(Object other) => (this of AbstractConfigurableEqualizer<T>).equals(other);
	
	compareTo(T first, T second) => first.compare(second);
}

shared class JavaObject<T> extends AbstractConfigurableEqualizer<T,Object?> satisfies Hasher<T> {
	
	shared new default() extends AbstractConfigurableEqualizer<T,Object?>(null) {}
	
	shared new (Object? equalityConfig) extends AbstractConfigurableEqualizer<T,Object?>(equalityConfig) {}
	
	hashCode(T first) => first?.hash else 0;
	
	areEquals(T first, T second) =>
		if (exists first, exists second) then first.equals(second)
		else ((first exists) == (second exists));
}

shared class NumberThreshold extends AbstractConfigurableEqualizer<Float,Integer>
		satisfies Comparator<Float> & Hasher<Float> {
	import java.math {
		RoundingMode,
		BigDecimal
	}
	
	static
	Integer defaultScale = 2;
	
	static
	Float round(Float val, Integer places) {
		assert (places >= 0);
		return BigDecimal(val.string).setScale(places, RoundingMode.halfUp).doubleValue();
	}
	
	shared new default() extends AbstractConfigurableEqualizer<Float,Integer>(defaultScale) {}
	
	shared new (Integer equalityConfig) extends AbstractConfigurableEqualizer<Float,Integer>(equalityConfig) {
	}
	
	shared actual Integer hashCode(Float obj) {
		return round(obj, scale).hash;
	}
	
	Integer scale => equalityConfig;
	
	shared actual Boolean areEquals(Float first, Float second) {
		Float absDiff = (first - second).magnitude;
		Float scaleRange = getScaleRange(scale);
		return absDiff.smallerThan(scaleRange);
	}
	
	Float getScaleRange(Integer scale) {
		return 1.0 / (10 ^ scale);
	}
	
	shared actual Integer compare(Float? first, Float? second) {
		return
			if (exists first, exists second) then (switch (compareTo(first, second)) case (equal) 0 case (smaller) -1 case (larger) 1)
			else if ((first exists) == (second exists)) then 0
				else if (first exists) then 1
					else -1;
	}
	
	shared actual Comparison compareTo(Float first, Float second) {
		Float diff = first - second;
		Float scaleRange = getScaleRange(scale);
		return if (diff.magnitude.smallerThan(scaleRange)) then equal else if (diff.negative) then smaller else larger;
	}
	
	shared actual Boolean equals(Object other) => (this of AbstractConfigurableEqualizer<Float,Integer>).equals(other);
}
