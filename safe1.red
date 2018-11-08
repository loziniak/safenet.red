Red []

#system [

	#define app_ptr! integer!

	all-chars: declare pointer! [integer!]
	all-chars/value: -1

	ffi_result!: alias struct! [
		error_code [integer!]
		error_description [c-string!]
	]

	#import [

		"libsafe_app.so" cdecl [

			safe_test_create_app: "test_create_app" [
; https://github.com/maidsafe/safe_client_libs/blob/master/safe_app/src/ffi/test_utils.rs
				app_id [c-string!]
				user_data [byte-ptr!]
				cb [byte-ptr!]
					;user_data [byte-ptr!]
					;result [ffi_result!]
					;app_ptr [app_ptr!]
			]
		]

	]

	call-cb: func [
		[typed]
		count [integer!] args [typed-value!]
		/local
			result-arg [typed-value!]
			result [ffi_result!]
			arg [typed-value!]
			cb [red-function!]
			cb-word [red-word!]
	] [
		stack/pop 2
		cb: as red-function! stack/top
		cb-word: as red-word! stack/top + 1

		result-arg: args + 0
		result: as ffi_result! result-arg/value

		print ["error_code: " result/error_code]

		either result/error_code = 0 [
			print lf
			stack/reset

			;-- TODO: the only reason for creating and passing 'cb_word'.
			;-- can we avoid this and use only 'cb'?
			;-- we could use anonymous functions then.
			stack/mark-func cb-word cb/ctx

			arg: args + 1
			count: count - 1
			until [
;				print ["type:" arg/type lf] ;-- DEBUG
				switch arg/type [
					type-integer! [
						integer/push arg/value
					]
					default [
						print ["WARNING: unsupported type: " arg/type lf]
					]
				]

				arg: arg + 1 ;-- next argument
				count: count - 1
				zero? count
			]

			_function/call cb global-ctx
			stack/unwind
		] [
			print [" error_description: " result/error_description lf]
		]
	]


	cb_safe_test_create_app: func [
		[cdecl]
		user_data [byte-ptr!]
		result [ffi_result!]
		app_ptr [app_ptr!]
		/local
			cb
			cb-word
	] [
		print ["cb_safe_test_create_app: " lf]
		call-cb [result app_ptr]
	]

] ; #system

test_create_app: routine [
	app-id [string!]
	cb-name [word!]
	/local
		app-id-cstr
] [
	app-id-cstr: unicode/to-utf8 app-id all-chars
	stack/push word/get cb-name
	word/push cb-name
	safe_test_create_app  app-id-cstr  as byte-ptr! 0  as byte-ptr! :cb_safe_test_create_app
]



print-tca: function [
	app-ptr [integer!]
] [
	print ["app-ptr:" app-ptr]
]


test_create_app "abcdef" 'print-tca
