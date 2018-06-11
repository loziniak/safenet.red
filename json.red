Red [
	Author: "loziniak"
	Description: "Basic JSON parser using 'parse dialect"
]

parser: object [
	builder: none

	process: function [txt [string!]] [
;		valid: parse-trace txt [_ [object | array] _]
		valid: parse txt [_ [object | array] _]
		if not valid [
			make error! [type: 'user id: 'message arg1: "Not a valid json"]
		]
		return builder/finish
	]


	ws: charset reduce [space tab cr lf]
	letter: charset [#"A" - #"Z" #"a" - #"z" #"_"]
	digit: charset "0123456789-"
	name-char: union letter digit
	not-name-char: complement name-char
	val-char: charset reduce ['not space tab cr lf "," "]" "}"]
	string-char: charset reduce ['not dbl-quote]

	_: [any ws]

	name: ["^"" copy n [letter [any name-char]] "^""]

	string: [copy p ["^"" any ["\^"" | string-char] "^""] (replace/all p "\^"" "\^^^"")]

	primitive: [string | [copy p some val-char]]

	values: [value (builder/add-to-block val)
			any [_ "," _ value (builder/add-to-block val)]]

	array: ["[" (builder/make-block)
			_ [values | none]
			_ "]"
		]

	value: [object (val: builder/take-map) 
			| array (val: builder/take-block)
			| primitive (val: load p)
		]

	pair: [name (builder/with-name n) _ ":" _ value (builder/add-to-map val)]

	pairs: [pair any [_ "," _ pair]]

	object: ["{" (builder/make-map) _ [pairs | none] _ "}"]

]

parser/builder: object [

	stack: copy []
	names: copy []


	make-block: function [] [append/only stack copy []]

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


compiler: object [
	process: function [what [map! block!]] [
		render what
	]

	render: function [v [default!] return: [string!]] [
		case [
			string? v [
				return rejoin ["^"" v "^""]
			]

			word? v [
				return render get v
			]

			(integer? v) or
			(float? v) or
			(logic? v) [
				return to-string v
			]

			(date? v) or
			(time? v) or
			(percent? v) or
			(char? v) [
				return render to-string v
			]

			block? v [
				rendered: copy ""
				foreach element v [
					append rendered  reduce [render element  ","]
				]
				if not empty? rendered [
					remove back tail rendered
				]
				insert rendered "["
				append rendered "]"
				return rendered
			]

			map? v [
				rendered: copy ""
				foreach key keys-of v [
					value: select v key
					append rendered  reduce ["^""  filter-key key  "^""  ":"  render value  ","]
				]
				if not empty? rendered [
					remove back tail rendered
				]
				insert rendered "{"
				append rendered "}"
				return rendered
			]
		]

		print ["Unsupported type:" type? v]
		return "null"
	]

	filter-key: function [key] [
		filtered: to-string key
		parse filtered [
			remove any [parser/not-name-char | parser/digit]
			1 parser/name-char
			any [parser/name-char | remove parser/not-name-char]
		]
		return filtered
	]
]


;-- example:

;a: parser/process " { ^"y^" : ^"a5^" , ^"x^":[33.50000, 2018-06-11T23:00:03.502Z, {^"a^":3}]   , ^"test^":^"123^" }"
;a: reduce [make map! [a 12.6 b 14.01%] make map! [a false b 14] now true]
;probe a

;b: compiler/process a
;probe b

;probe parser/process b
