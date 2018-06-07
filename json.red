Red [
	Author: "loziniak"
	Description: "Basic JSON parser using 'parse dialect"
]

parser: object [
	builder: none

	process: function [txt [string!]] [
		valid: parse txt [_ object _]
		if not valid [
		]
		return builder/finish
	]


	ws: charset reduce [space tab cr lf]
	letter: charset [#"A" - #"Z" #"a" - #"z" #"_"]
	digit: charset "0123456789-"
	val-char: charset reduce ['not space tab cr lf "," "]" "}"]
	string-char: charset reduce ['not dbl-quote]

	_: [any ws]

	name: ["^"" copy n [letter [any [letter | digit]]] "^""]

	string: ["^"" any string-char "^""]

	primitive: [copy p [string | any val-char]]

	array: ["[" (builder/make-block)
			_ value (builder/add-to-block val)
			any [_ "," _ value (builder/add-to-block val)]
			_ "]"
		]

	value: [object (val: builder/take-map) 
			| array (val: builder/take-block)
			| primitive (val: load p)
		]

	pair: [name (builder/with-name n) _ ":" _ value (builder/add-to-map val)]

	object: ["{" (builder/make-map) _ pair any [_ "," _ pair] _ "}"]

]

parser/builder: object [

	stack: []
	names: []


	make-block: function [] [append/only stack []]

	add-to-block: function [v [default!]] [
		append/only last stack v
	]

	take-block: function [] [
		if not block? last stack [
			make error! [type: 'user id: 'message arg1: "Not a block"]
		]
		take/last stack
	]


	make-map: function [] [append stack make map! []]

	with-name: function [name [string!]] [append names to word! name]

	add-to-map: function [v [default!]] [
		put last stack take/last names v
	]

	take-map: function [] [
		if not map? last stack [
			make error! [type: 'user id: 'message arg1: "Not a map"]
		]
		take/last stack
	]

	finish: function [] [
		if 1 <> length? stack [
			make error! [type: 'user id: 'message arg1: "Not a last stack element"]
		]
		take/last stack
	]
]




;-- example:

probe parser/process " { ^"y^" : a5 , ^"x^":[33.50000, 12-12-2012, {^"a^":3}]   , ^"test^":^"123^" }"
