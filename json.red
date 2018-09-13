Red [
	Author: "loziniak"
	Description: "Basic JSON parser and generator using 'parse dialect"
]

parser: object [
	builder: none

	process: function [txt [string!]] [
;		valid: parse-trace txt [_ [object | array] _]
		valid: parse txt [_ [object | array] _]
		if not valid [
			do make error! [type: 'user id: 'message arg1: "Not a valid json"]
		]
		return builder/finish
	]

	null-word: 'nul ;-- cannot use 'null, because in Red it's a synonym to #"^@"

	ws: charset reduce [space tab cr lf]
	letter: charset [#"A" - #"Z" #"a" - #"z" #"_"]
	digit: charset "0123456789-"
	name-char: union letter digit
	not-name-char: complement name-char
	val-char: charset reduce ['not space tab cr lf "," "]" "}"]
	string-char: charset reduce ['not dbl-quote]

	_: [any ws]

	name: ["^"" copy n [any name-char] "^""]

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
			| "null" (val: null-word)
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
			do make error! "Not a block"
		]
		take/last stack
	]


	make-map: function [] [append stack make map! []]

	with-name: function [name [string!]] [
		first-letter: to integer! first name
		letters: parser/letter

		either not letters/:first-letter [
			key: to string! name
		] [
			key: to word! name
		]
		append names key
	]

	add-to-map: function [v [default!]] [
		put last stack take/last names v
	]

	take-map: function [] [
		if not map? last stack [
			do make error! "Not a map"
		]
		take/last stack
	]


	finish: function [] [
		if 1 <> length? stack [
			do make error! "Not a last stack element"
		]
		take/last stack
	]
]


generator: object [
	process: function [what [map! block!]] [
		render what
	]

	render: function [v [default!] return: [string!]] [
		case [
			string? v [
				return rejoin ["^"" v "^""]
			]

			word? v [
				either v = parser/null-word [
					return "null"
				] [
					return render get v
				]
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
		digit: parser/digit ;-- parse does not evaluate paths, only words
		name-char: parser/name-char
		not-name-char: parser/not-name-char

		filtered: to-string key
		parse filtered [
			any [name-char | remove not-name-char]
		]
		return filtered
	]
]
