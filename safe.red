Red [
	Author: "loziniak"
	Description: "Safe Network API bindings. See: https://github.com/maidsafe/safe_client_libs"
]

#system [
#import [
	"libsafe_app.so" cdecl [
		safe_is_mock_build: "is_mock_build" [
			return: [logic!]
		]
	]
]
]

is_mock_build: routine [
	return: [logic!]
][
	safe_is_mock_build
]

print ["Is mock: " is_mock_build]
