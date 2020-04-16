=head2 DESCRIPTION
Custom operators that work on non-custom types, which is surprising behaviour

#| Used to optionally pass named arguments. It is tighter than a comma, so you can omit the parentheses
#| eg. function $some-arg, |with-val named => $maybe-undef, $other-arg
multi sub prefix:<with-val> (Pair:D $pair) is equiv(&prefix:<so>) is export {
	$pair with $pair.value orelse Empty
}