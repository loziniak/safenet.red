Red []


suite: object [
	tests: []

	expect: function [
		expected [any-type!]
		code [block!]
	] [
		append/only tests make map! reduce ['code code 'expected expected]
	]

	run: function [] [
		outcome: object [
			failed: 0
			passed: 0
;			positive?: false
		]

		foreach test tests [
			result: do test/code
			either strict-equal? result test/expected [
				outcome/passed: outcome/passed + 1
			] [
				outcome/failed: outcome/failed + 1
				print ["Failed:" mold test/code
					"^/    Expected" mold test/expected "but got" mold result]
			]

		]

		return outcome
	]

]
