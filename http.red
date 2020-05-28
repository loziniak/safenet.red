Red [
	Author: "loziniak"
	Description: "HTTP client using curl command"
]

; alternative:
; https://github.com/red/red/wiki/%5BDOC%5D-Guru-Meditations#how-to-make-http-requests

request: object [
	url: none
	method: 'GET
	headers: #()
	data: none
	urlencode-data: true
	response: object [
		status: none
		body: none
	]

	execute: function [] [
		this-request: self
		if none? url [
			do make error! "No url."
		]

		either system/platform = 'Windows [
			executable: "curl.exe"
			platform-options: "--insecure"
		] [
			executable: "curl"
			platform-options: ""
		]

		this-request/data: prepare-data this-request/data

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
			executable " -i " platform-options " "
			"-X " this-request/method " "
			headers-options
			"--data ^"" either none? this-request/data [""] [this-request/data] "^" "
			"^"" mold to url! this-request/url "^""
		]

		result: call/output/error command out err
		either result == 0 [
			response: http-parser/process out
			this-request/response: response

			if any [
				response/status >= 500
			] [
				do make error! rejoin [
					"HTTP status " response/status
					": " response/status-message
					", Body: " response/body
				]
			]
		] [
			do make error! rejoin ["Curl error: " err]
		]
	]

	prepare-data: function [
		d [string! none!]
	] [
		either none? d [
			none
		] [
			ret: copy ""
			either urlencode-data [
				ret: mold to url! d
				replace/all ret #"&" "%26"
				replace/all ret #":" "%3A"
				replace/all ret #"/" "%2F"
				replace/all ret #"#" "%23"
				replace/all ret #"?" "%3F"
				replace/all ret #"\" "%5C"
			] [
				ret: copy d
				replace/all ret #"\" "\\"
				replace/all ret #"^"" "\^""
			]
			ret
		]
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
			["HTTP/1.1 " | "HTTP/2 "]
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
			return: [object!]
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
