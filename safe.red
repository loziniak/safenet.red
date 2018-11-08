Red [
	Author: "loziniak"
	Description: "Safe Network API bindings. Library sources: https://github.com/maidsafe/safe_client_libs"
	Usage: "./red -c -r -o bin/safe safe.red"
]


#system [

	#define app_ptr! integer!

	int64!: alias struct! [
		i1 [integer!]
		i2 [integer!]
	]

	all-chars: declare pointer! [integer!]
	all-chars/value: -1

	ffi_result!: alias struct! [
		error_code [integer!]
		error_description [c-string!]
	]

	ffi_account_info!: alias struct! [
		mutations_done [int64!]
		mutations_available [int64!]
	]


	#import [

		"libsafe_app.so" cdecl [

			safe_is_mock_build: "is_mock_build" [
	; https://github.com/maidsafe/safe_client_libs/blob/master/safe_core/src/ffi/mod.rs
				return: [logic!]
			]

			;--	Does it work for app created with test_create_app?
			safe_app_account_info: "app_account_info" [
	; https://github.com/maidsafe/safe_client_libs/blob/master/safe_app/src/ffi/mod.rs
				app_ptr [app_ptr!]
				user_data [byte-ptr!]
				cb [byte-ptr!]
					;user_data [byte-ptr!]
					;result [ffi_result!]
					;account_info [ffi_account_info!]
			]

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

	#import [

		"libsystem_uri.so" cdecl [

			system_open_uri: "open_uri" [
	; https://github.com/maidsafe/system_uri/blob/master/src/linux.rs
				uri [c-string!]
				user_data [byte-ptr!]
				cb [byte-ptr!]
					;user_data [byte-ptr!]
					;result [ffi_result!]
			]
		]
	]



	cb_void: func [
		[cdecl]
		user_data [byte-ptr!]
		result [ffi_result!]
		/local
			cb
			cb-word
	] [
		print "cb_void: "
		stack/pop 2
		cb: as red-function! stack/top
		cb-word: as red-word! stack/top + 1

		print "error_code: "
		print result/error_code

		either result/error_code = 0 [
			print lf
			stack/reset
			stack/mark-func cb-word cb/ctx
			_function/call cb global-ctx
			stack/unwind
		] [
			print " error_description: "
			print result/error_description
			print lf
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
		print "cb_safe_test_create_app: "
		stack/pop 2
		cb: as red-function! stack/top
		cb-word: as red-word! stack/top + 1

		print "error_code: "
		print result/error_code

		either result/error_code = 0 [
			print lf
			stack/reset

			;-- TODO: the only reason for creating and passing 'cb_word'.
			;-- can we avoid this and use only 'cb'?
			;-- we could use anonymous functions then.
			stack/mark-func cb-word cb/ctx

			integer/push app_ptr
			_function/call cb global-ctx
			stack/unwind
		] [
			print " error_description: "
			print result/error_description
			print lf
		]
	]

	cb_safe_app_account_info: func [
		[cdecl]
		user_data [byte-ptr!]
		result [ffi_result!]
		account_info [ffi_account_info!]
		/local
			cb
			cb-word
	] [
		print "cb_safe_app_account_info: "
		stack/pop 2
		cb: as red-function! stack/top
		cb-word: as red-word! stack/top + 1

		print "error_code: "
		print result/error_code

		either result/error_code = 0 [
			print lf
			stack/reset
			stack/mark-func cb-word cb/ctx
			integer/push account_info/mutations_done/i2
			integer/push account_info/mutations_available/i2
			_function/call cb global-ctx
			stack/unwind
		] [
			print " error_description: "
			print result/error_description
			print lf
		]
	]

] ; #system




is_mock_build: routine [
	"Returns true if libsafe_app was compiled against mock-routing."
	return: [logic!]
][
	safe_is_mock_build
]

test_create_app: routine [
	app-id [string!]
	cb-name [word!]
	/local
		app-id-cstr
] [
	app-id-cstr: unicode/to-utf8 app-id all-chars
	stack/push as red-value! word/get cb-name
	stack/push as red-value! cb-name
	safe_test_create_app  app-id-cstr  as byte-ptr! 0  as byte-ptr! :cb_safe_test_create_app
]

app_account_info: routine [
	app-ptr [integer!]
	cb-name [word!]
] [
	print "appptr"
	print app-ptr
	stack/push as red-value! word/get cb-name
	stack/push as red-value! cb-name
	safe_app_account_info  app-ptr  as byte-ptr! 0  as byte-ptr! :cb_safe_app_account_info ;-- no reaction. callback not fired.
]

open_uri: routine [
	uri [string!]
	cb-name [word!]
	/local
		uri-cstr
] [
	uri-cstr: unicode/to-utf8 uri all-chars
	stack/push as red-value! word/get cb-name
	stack/push as red-value! cb-name
	system_open_uri  uri-cstr  as byte-ptr! 0  as byte-ptr! :cb_void
]




print-ok: function [] [
	print "OK"
]

print-aai: function [
	mutations-done [integer!]
	mutations-available [integer!]
] [
	print ["mutations-done:" mutations-done]
	print ["mutations-available:" mutations-available]
]

print-tca: function [
	app-ptr [integer!]
] [
	print ["app-ptr:" app-ptr]

	; then
	app_account_info app-ptr 'print-aai
]


;test_create_app "abcdef" 'print-tca
open_uri "http://diasp.eu" 'print-ok
