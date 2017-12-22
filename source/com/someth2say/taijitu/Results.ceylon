import ceylon.language.meta {
	type
}

shared abstract class Difference<T> {
	Equalizer<out T> cause;
	List<T> entries;
	{Difference<Anything>*} underlyingDifferences;
	
	shared new (Equalizer<out T> cause, List<T> entries, {Difference<Anything>*} underlyingDifferences) {
		this.cause = cause;
		this.entries = entries;
		this.underlyingDifferences = underlyingDifferences;
	}
	
	shared new forEntryWithDifferences(Equalizer<T> cause, T entry, {Difference<Anything>*} underlyingDifferences)
			extends Difference<T>(cause, [entry], underlyingDifferences) {}
	
	shared new forEntry(Equalizer<T> cause, T entry)
			extends Difference<T>(cause, [entry], empty) {}
	
	shared new forEntries(Equalizer<out T> cause, T entry, T entry2)
			extends Difference<T>(cause, [entry, entry2], empty) {}
	
	shared new forEntriesWithDifferences(Equalizer<T> cause, T entry, T entry2, {Difference<Anything>*} underlyingDifferences)
			extends Difference<T>(cause, [entry, entry2], underlyingDifferences) {}
	
	string => "``className(type(this))``: ``cause``(``if (underlyingDifferences.empty) then entries else underlyingDifferences``)";
	
	equals(Object o) => if (this==o) then true else if (is Difference<T> o) then cause.equals(o.cause) && entries.equals(o.entries) else false;
	
	hash => [entries,cause].fold(1)((i,element)=>31 * i + element.hash);
}

shared class Missing<T> extends Difference<T> {
	shared new (Equalizer<T> cause, T entry) extends Difference<T>.forEntry(cause, entry){}
}

shared class Unequal<T> extends Difference<T> {
	shared new (Equalizer<T> cause, T entry, T entry2, {Difference<Anything>*} underlyingDifferences)
			extends Difference<T>(cause, [entry, entry2], underlyingDifferences) {
	}
	
	shared new withoutUnderlying(Equalizer<out T> cause, T entry, T entry2) extends Difference<T>.forEntries(cause, entry, entry2) {
	}
}
