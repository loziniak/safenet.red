Red []

do %test.red
do %json.red


json-test: make suite []
json-test/expect #(abc: nul) [parser/process "{^"abc^":null}"]
json-test/expect "{^"abc^":null}" [generator/process parser/process "{^"abc^":null}"]


result: json-test/run
probe result
