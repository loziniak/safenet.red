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

	cb_safe_test_create_app: func [
		[cdecl]
		user_data [byte-ptr!]
		result [ffi_result!]
		app_ptr [app_ptr!]
		/local
			cb-code
	] [
		print "cb_safe_test_create_app: "
		stack/pop 1
		cb-code: as red-block! stack/top

		print "error_code: "
		print result/error_code

		either result/error_code = 0 [
			print lf

			;-- how to pass "app_ptr" to trampoline?
			;-- something like "integer/push app_ptr"?

			#call [trampoline cb-code]

		] [
			print " error_description: "
			print result/error_description
			print lf
		]

	]

] ; #system


trampoline: function [
	cb-code [block!]
] [
	;-- how to retrieve arguments?
	do cb-code
]


test_create_app: routine [
	app-id [string!]
	cb-code [block!]
	/local
		app-id-cstr
] [
	app-id-cstr: unicode/to-utf8 app-id all-chars
	block/push cb-code
	safe_test_create_app  app-id-cstr  as byte-ptr! 0  as byte-ptr! :cb_safe_test_create_app
]



test_create_app "abcdef" [
	function [
		app-ptr [integer!]
	] [
		print ["app-ptr:" app-ptr]
	]
]
