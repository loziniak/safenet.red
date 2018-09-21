Red [
	Usage: "./red-21may18-9e5803bb -c -e -o bin/e e.red"
]

a: function [
	num [integer!]
] [
	print "num: "
	print num
]

b: function [
	cb [function!]
	num [integer!]
] [
;	cb: function spec-of :cb body-of :cb
	cb num
]

b :a 15

comment {
https://gitter.im/red/help?at=5ba42aa4e5c2cc56adbd3be8
Hello! I'm trying to compile a Red code with callback function.
This does work only in interpreted mode. I've read https://github.com/red/red/wiki/%5BDOC%5D-Guru-Meditations#compiled-vs-interpreted-macros
but uncommenting a commented line in my code also does not help.

@loziniak remove this line completely, as it's not needed, and compile with -e flag.

It compiles in encap mode, which doesn't really compile, but stores the source
in the exe for runtime interpretation. It lets you work around any compiler limitations.

And will it allow me to mix R/S code with Red, using routines and #system?

* Routines can be used as long as they are globally defined.
* #system (if it has no local effect) and #system-global directives are supported.
* #include is supported.
* Your Red code is converted to Redbin format and compressed.
}
