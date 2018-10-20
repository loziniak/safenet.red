Red/System []

#define app_ptr! byte-ptr!

ffi_result!: alias struct! [
; https://github.com/maidsafe/ffi_utils/blob/master/src/lib.rs
	error_code [integer!]
	error_description [c-string!]
]

#import [

	"libsafe_app.so" cdecl [

		safe_test_create_app: "test_create_app" [
; https://github.com/maidsafe/safe_client_libs/blob/master/safe_app/src/ffi/test_utils.rs
			app_id [c-string!]
			user_data [byte-ptr!]
			cb [integer!]
		]
	]
]


cb: func [
	[cdecl]
	user_data [byte-ptr!]
	result [ffi_result!]
	app_ptr [app_ptr!]
] [
	print "error_code: "
	print result/error_code
	either result/error_code = 0 [
		print " app_ptr: "
		print app_ptr
	] [
		print " error_description: "
		print result/error_description
	]
	print lf
]

safe_test_create_app  "abcdef"  as byte-ptr! 0  as integer! :cb
