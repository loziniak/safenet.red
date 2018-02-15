Red [
	Author: "loziniak"
	Description: "Training dynamic library calls"
]

#system [
#import [
	"/usr/lib32/libc.so.6" cdecl [
		libc_pid: "getpid" [
			return: [integer!]
		]
	]
]
]

pid: routine [
	return: [integer!]
][
	libc_pid
]

print ["My pid: " pid]
