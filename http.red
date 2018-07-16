Red [
	Author: "loziniak"
	Description: "HTTP client using curl command"
]


request: object [
	url: none
	method: 'GET
	headers: #()
	data: none
	urlencode-data: true
	response: none

	execute: function [] [
		if none? url [
			do make error! "No url."
		]

		self/data: prepare-data self/data

		out: copy ""
		err: copy ""

		headers-options: copy ""
		foreach header keys-of headers [
			append headers-options rejoin [
				"-H ^""
				header
				": "
				select/case headers header
				"^" "
			]
		]

		command: rejoin [
			"curl -i "
;			"--trace-ascii % "
			"-X " method " "
			headers-options
			"--data ^"" self/data "^" "
			"^"" mold to url! url "^""
		]
;		probe self/data
;		probe command

		result: call/output/error command out err
;		probe result
;		probe out
;		probe err
		either result == 0 [
			self/response: http-parser/process out

			if self/response/status >= 300 [
;			if not self/response/status = 200 [
				do make error! rejoin [
					"HTTP status " self/response/status
					": " self/response/status-message
					", Body: " self/response/body
				]
			]
		] [
			do make error! rejoin ["Curl error: " err]
		]
	]

	prepare-data: function [
		d [string! none!]
	] [
		ret: copy []
		unless none? d [
			either urlencode-data [
				ret: mold to url! d
			] [
				ret: copy d
				replace/all ret #"\" "\\"
				replace/all ret #"^"" "\^""
			]
		]
		return ret
	]

	http-parser: object [
		response: object [
			status: none
			status-message: none
			headers: none
			body: none
		]

		ws: charset reduce [space tab]
		_: [any ws]
		digit: charset "0123456789"
		letter: charset [#"A" - #"Z" #"a" - #"z" #"_"]
		header-value: charset reduce ['not crlf]
		cr?lf: charset reduce [cr lf]
		anything: charset reduce ['not ""]

		status: [
			"HTTP/1.1 "
			copy s [3 digit] (response/status: to integer! s)
			" "
			copy sm [any header-value] (response/status-message: sm)
		]

		body: [copy b [any anything] (response/body: b)]

		headers: [
			any [
				copy n [any [letter | "-"]] ": "
				copy v [any header-value] cr?lf 
				(put response/headers n v)
			]
		]

		response-rule: [
			some [
				status cr?lf
				headers
				0 1 cr?lf
			]
			0 1 body
		]

		process: function [
			curl-output [string!]
		] [
			self/response: make response [
				status: 200
				status-message: ""
				headers: #()
				body: ""
			]

			valid: parse curl-output response-rule
			if not valid [
				do make error! rejoin ["Not a valid curl output: " curl-output]
			]
			return response
		]
	]

]
