stjck specification DRAFT
=========================

This is the official DRAFT specification of the stjck programming language.
Stjck is a stack-based language. It has one data type, stacks. The language
has several builtin functions for pushing and popping onto the stacks as
well as a handful of combinators that can be applied to the stack manipulation
functions. There are also limited control flow operators.


Note about undefined behavior
-----------------------------

One of the design goals of the stjck programming language is that it should be
easy to implement. However, many of the builtin functions in the language can
result in logically unsound programs (such as popping from an empty stack). To
make implementation of the language simpler, logically unsound code is
considered to have undefined behavior. Thus it is the job of the implementor
to determine how best to handle undefined behavior.

For ease, some suggestions for undefined behavior are provided:

 - Display an error message and terminate.
 - Terminate silently
 - Return an empty stack and continue
 - Enter an infinite loop
 - Introduce memory corruption
 - Shell out and run "rm -fr ~"
 - E-mail the user and notify them of undefined behavior
 - All of the above (may not ease implementation)

Undefined behavior can occur at runtime or compile time.


Builtin Functions
-----------------

> and < are the core stack manipulation functions. > takes a stack as input
and returns that stack with an empty stack pushed onto it. < pops the top
of of a stack and returns the tail of the stack.

| is the identity function. It returns its input.

; returns the first item in a stack.

. takes a stack as input and returns an empty stack.

- and _ are the output functions. - takes a stack as input and prints out a
byte with a value equal to the size of the stack. _ prints a byte, but
attempts to interpret the stack as a binary value, with the top of the
stack representing the most significant byte. Any empty stacks in the stack
count as a 0 bit, stacks with 1 item count as a 1 bit. Stacks with more bits
may result in undefined behavior. Both functions return the stack intact.



Combinators
-----------

There are two combinators for modifying the stack manipulation functions. For
ease in implementation, they are applied as postfix operators.

' is the on-head combinator. It takes a function returns a function that
applies the input function to the head of a stack.

" is the on-tail combinator. It takes a function and returns a function that
applies the input function to the tail of a stack.

These combinators can be stacked to access arbitrary items in the stack.

? is technically a combinator, though it resembles a control flow operator.
Unlike the ' and " combinators, it applies to the previous three functions.
It works by applying the function immediately preceeding it to the stack.
If that evaluates to an empty stack, then it will evaluate the function
preceeding the evaluator function. Otherwise, it will evaluate the third
left most function.

Control Structures
------------------

[ and ] are the compose wrapper. Any functions in between them are composed
together to a single function. Interpretation should be such that the left
most function is the first applied with its result passed to the next function
and so on. With, of course, the combinator functions still being applied
postfix.

\ is the compose-head operator. It evaluates to the head of the current compose
wrapper. This operator can be stacked, with \\ jumping to the head of the next
most current compose operator. Any \ that jumps past the outermost [ will
result in undefined behavior.

Other Characters
----------------
It is recommended, but not required, that whitespace be ignored in stjck
implementations. Other characters should result in undefined behavior.


