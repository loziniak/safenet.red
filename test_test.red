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



print "^/AUTO-TEST..."

try-error-outcome: function [
] [
	test: make suite []
	test/try-error [1 / 1]
	test/try-error [1 / 0]
	return test/run
]

test-test: make suite []
test-test/expect #(failed: 1 passed: 1) [try-error-outcome]

results: test-test/run
print "results"
print results
either results/failed > 0 [
	print "... FAILED!"
] [
	print "... PASSED!"
]
