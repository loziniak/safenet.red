Red/System [
	Author: "loziniak"
	Description: "Training dynamic library calls"
]

#import [
	"/usr/lib32/libc.so.6" cdecl [
		libc_pid: "getpid" [
			return: [integer!]
		]
	]
]

pid: func [return: [integer!]] [libc_pid]

print pid
