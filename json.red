Red [
	Author: "loziniak"
	Description: "Very basic JSON parser using 'parse dialect"
]

structures: []
names: []

ws: charset reduce [space tab cr lf]
letter: charset [#"A" - #"Z" #"a" - #"z" #"_"]
digit: charset "0123456789-"
val-char: charset reduce ['not space tab cr lf "," "]" "}"]
string-char: charset reduce ['not dbl-quote]

_: [any ws]

name: ["^"" copy n [letter [any [letter | digit]]] "^"" (append names to word! n)]

string: ["^"" any string-char "^""]

primitive: [copy p [string | any val-char] (p: load p)]

array: ["[" (append/only structures [])
		_ value (append/only last structures v) any [_ "," _ value (append/only last structures v)] _ "]"]

value: [object (v: take/last structures) | array (v: take/last structures) | primitive (v: p)]

pair: [name _ ":" _ value (put last structures take/last names v)]

object: ["{" (append structures make map! []) _ pair any [_ "," _ pair] _ "}"]


;-- example:

print parse " { ^"y^" : a5 , ^"x^":[33.50000, 12-12-2012, {^"a^":3}]   , ^"test^":^"123^" }" [_ object _]

probe last structures
