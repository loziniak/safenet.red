Red []

do %http.red
do %test.red
do %json.red

httpbin-url: function [
	return: [string!]
] [
	get-req: make request [
		url: http://httpbin.org/get
	]
	get-req/execute
	
	body-json: parser/process get-req/response/body
	body-json/url
]


http-test: make suite []
http-test/expect "http://httpbin.org/get" [httpbin-url]


result: http-test/run
probe result
