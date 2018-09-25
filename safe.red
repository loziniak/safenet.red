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
; https://github.com/maidsafe/safe_client_libs/blob/cf8fa8829d1b8ed56b83f8724da97b31c6918603/safe_core/src/ffi/mod.rs#L72
			return: [logic!]
		]

		safe_app_account_info: "app_account_info" [
; https://github.com/maidsafe/safe_client_libs/blob/cf8fa8829d1b8ed56b83f8724da97b31c6918603/safe_app/src/ffi/mod.rs#L142
			app_ptr [app_ptr!]
			user_data [byte-ptr!]
			cb [function! [
				user_data [byte-ptr!]
				result [ffi_result!]
				account_info [ffi_account_info!]]]
		]
	]
]

] ; #system


is_mock_build: routine [
	"Returns true if libsafe_app was compiled against mock-routing."
	return: [logic!]
][
	safe_is_mock_build
]


app_account_info: routine [
	"Get the account usage statistics (mutations done and mutations available)."
	app-ptr* [integer!]
	red-callback [function!]
	;   [mutations_done [integer!]   mutations_available [integer!]   error_code [integer!]   error_description [string!]]
][

	cb: func [ ;-- Based on Red's runtime block/compare-call code
		[cdecl]
		user_data [byte-ptr!] ;-- discarded
		result [ffi_result!]
		account_info [ffi_account_info!]
	][
		; TODO: check red-callback's arguments spec (count? types?)
		integer/push account_info/mutations_done/i2
		integer/push account_info/mutations_available/i2
		integer/push result/error_code
		string/push string/load
			result/error_description
			size? result/error_description
			UTF-8
;?		_function/call red-callback   ;-- ("undefined symbol: red-callback") How to make routine argument is not accessible? (reference: https://github.com/meijeru/red.specs-public/blob/master/specs.adoc#745-routine-type )
		stack/unwind
;?		stack/pop 1   ;-- Is it necessary? Callback should not return anything. But if it does, how to discard returned value?
	]

	safe_app_account_info app-ptr* null :cb
]
