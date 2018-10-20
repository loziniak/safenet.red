Red/System [
	Author: "loziniak"
	Description: "Safe Network API bindings."
	Usage: "./red -c -r -o bin/safe safe.reds"
]

#define app_ptr! byte-ptr!

int64!: alias struct! [
	i1 [integer!]
	i2 [integer!]
]

ffi_result!: alias struct! [
; ffi_utils/blob/master/src/lib.rs
	error_code [integer!]
	error_description [c-string!]
]

ffi_account_info!: alias struct! [
	mutations_done [int64!]
	mutations_available [int64!]
]

ok?: func [
	result [ffi_result!]
	return: [logic!]
] [
	result/error_code = 0
]

#import [

	"libsafe_app.so" cdecl [

		safe_is_mock_build: "is_mock_build" [
; safe_client_libs/safe_core/src/ffi/mod.rs
			return: [logic!]
		]

		safe_app_account_info: "app_account_info" [
; safe_client_libs/safe_app/src/ffi/mod.rs
			app_ptr [app_ptr!]
			user_data [byte-ptr!]
			cb [function! [
				user_data [byte-ptr!]
				result [ffi_result!]
				account_info [ffi_account_info!]]]
		]

		safe_test_create_app: "test_create_app" [
; safe_client_libs/safe_app/src/ffi/test_utils.rs
			app_id [c-string!]
			user_data [byte-ptr!]
			cb [integer!]
		]
	]
]


print "mock: "
print safe_is_mock_build



;cb1: func [
;	[cdecl]
;	user_data [byte-ptr!] ;-- discarded
;	result [ffi_result!]
;	account_info [ffi_account_info!]
;] [
;	print " mutations_done: "
;	print account_info/mutations_done/i2
;	print " mutations_available: "
;	print account_info/mutations_available/i2
;
;	print " error_code: "
;	print result/error_code
;	print " error_description: "
;	print result/error_description
;]

;safe_app_account_info  as app_ptr! 0  as byte-ptr! 0  :cb1


cb2: func [
	[cdecl]
	user_data [byte-ptr!]
	result [ffi_result!]
	app_ptr [app_ptr!]
] [
;	print " app_ptr: "
;	print app_ptr

;	print " error_code: "
;	print result/error_code
;	print " error_description: "
;	print result/error_description
]

safe_test_create_app  "abcdef"  as byte-ptr! 0  as integer! :cb2



;-- TODO:
;-- 
;-- ? app_init_logging(filename, user_data, cb)   // @ffi/mod.rs
;-- 	cb: fn(user_data: *mut c_void, result: *const FfiResult)
;-- 
;-- ? app_set_additional_search_path(new_path, user_data, cb)   // @ffi/mod.rs
;-- 	cb: fn(user_data: *mut c_void, result: *const FfiResult)
;-- 
;-- test_create_app(app_id, user_data, cb)   // Creates a random app instance for testing. @ffi/test_utils.rs. only with mock_routing
;-- 	cb: fn(user_data: *mut c_void, result: *const FfiResult, app: *mut App)	
;-- 
