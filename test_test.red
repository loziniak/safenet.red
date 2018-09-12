Red [
	File: %test_test.red
	Author: "loziniak"
	Description: "Testing framework auto-test"
]

#include %test.red

expect-test: make suite []
expect-test/expect "wow" ["wow"]
expect-test/expect "wow" ["shit"]

outcome: expect-test/run

either (type? outcome) = map! [
	print "SUCCESS: outcome is a map"
] [
	print ["FAIL: outcome is NOT a map!, but" type? outcome]
	quit
]

either outcome = #(failed: 1 passed: 1) [
	print "SUCCESS: proper failed and passed count."
] [
	print ["FAIL: outcome is:" outcome "."]
	quit
]


test-test: make suite []

try-error-outcome: function [
] [
	test: make suite []
	test/try-error [1 / 1]
	test/try-error [1 / 0]
	return test/run
]
test-test/expect #(failed: 1 passed: 1) [try-error-outcome]

print "^/"
results: test-test/run
print "results"
print results
if results/failed > 0 [
	quit
]


;-- we got here finally, soooo...
print "^/AUTO-TEST PASSED!"
