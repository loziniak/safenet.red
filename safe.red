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
; https://github.com/maidsafe/safe_client_libs/blob/master/safe_core/src/ffi/mod.rs#L72
			return: [logic!]
		]

		safe_app_account_info: "app_account_info" [
; https://github.com/maidsafe/safe_client_libs/blob/master/safe_app/src/ffi/mod.rs#L142
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

cb_safe_test_create_app: func [
	[cdecl]
	user_data [byte-ptr!]
	result [ffi_result!]
	app_ptr [app_ptr!]
	/local
		cb
		cb-word
] [
	stack/pop 2
	cb: as red-function! stack/top
	cb-word: as red-word! stack/top + 1

	print "error_code: "
	print result/error_code

	either result/error_code = 0 [
		print lf
		stack/reset
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

comment { unsuccessful trials, for reference:
#system [
	app_account_info_cb: func [
		[cdecl]
		user_data [byte-ptr!] ;-- discarded
		result [ffi_result!]
		account_info [ffi_account_info!]
		/local
			cb [red-function!]
			cb-ctx [node!]
	][
		; TODO: check red-callback's arguments spec (count? types?)
		cb: as red-function! stack/pop 1
		cb-ctx: cb/ctx   ;?-- not sure of that. maybe cb/more/obj/ctx should be more appropriate?

		integer/push account_info/mutations_done/i2
		integer/push account_info/mutations_available/i2
		integer/push result/error_code
		string/push string/load
			result/error_description
			size? result/error_description
			UTF-8

		_function/call cb cb-ctx   ;-- Based on Red's runtime block/compare-call code

		stack/unwind
		stack/pop 1   ;?-- Is it necessary? Callback should not return anything. But if it does, how to discard returned value?
	]
]

app_account_info: routine [
	"Get the account usage statistics (mutations done and mutations available)."
	app-ptr* [integer!]
	red-callback [function!]
	; spec: [mutations_done [integer!]   mutations_available [integer!]   error_code [integer!]   error_description [string!]]
][
	stack/push as red-value! red-callback
	safe_app_account_info app-ptr* null :app_account_info_cb
]

} ;comment

print-tca: function [
	app-ptr [integer!]
] [
	print ["app-ptr:" app-ptr]
]


test_create_app "abcdef" 'print-tca
