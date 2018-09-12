Red []


suite: object [
	tests: []
	trials: []

	expect: function [
		expected [any-type!]
		code [block!]
	] [
		append/only tests make map! reduce ['code code 'expected expected]
	]

	try-error: function [
		code [block!]
	] [
		append/only trials make map! reduce ['code code]
	]

	run: function [] [
		outcome: make map! [
			failed 0
			passed 0
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

		foreach trial trials [
			set/any 'result try trial/code
			either error? :result [
				outcome/failed: outcome/failed + 1
				print ["Failed:" mold trial/code
					"^/" mold :result]
			] [
				outcome/passed: outcome/passed + 1
			]
		]

		return outcome
	]

]
