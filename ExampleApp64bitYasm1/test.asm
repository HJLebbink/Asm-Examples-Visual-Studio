.intel_syntax noprefix
.text			# Code section

#region entry testCode_linux

testCode_linux:
.global testCode_linux

# extern "C" void testCode_linux(
#	unsigned long * const data,
#	const unsigned long long nItems1, 
#	const unsigned long long nItems2, 
#	const unsigned long long nItems3);
#
# testCode_linux(unsigned long * const data, const unsigned long long nItems1, const unsigned long long nItems2, const unsigned long long nItems3);
# rdi <= data
# rsi <= nItems1
# rdx <= nItems2
# rcx <= nItems3

# The calling convention of the System V AMD64 ABI[14] is followed on Solaris, Linux, FreeBSD, OS X, 
# and other UNIX-like or POSIX-compliant operating systems. The first six integer or pointer arguments
# are passed in registers RDI, RSI, RDX, RCX, R8, and R9, while XMM0, XMM1, XMM2, XMM3, XMM4, XMM5, XMM6
# and XMM7 are used for floating point arguments. For system calls, R10 is used instead of RCX. 
# As in the Microsoft x64 calling convention, additional arguments are passed on the stack and the 
# return value is stored in RAX.
#
# shuffle the registers to be equal to windows ABI
	mov			r9,		rcx
	mov         rcx,	rdi
	mov         r8,		rdx
	mov         rdx,	rsi
#endregion
#region entry testCode_windows

testCode_windows:
.global testCode_windows

# extern "C" void testCode_windows(
#	unsigned long * const data, 
#	const unsigned long long nItems1, 
#	const unsigned long long nItems2, 
#	const unsigned long long nItems3)
#
# rcx <= data
# rdx <= nItems1
# r8 <= nItems2
# r9 <= nItems3

# The Microsoft x64 calling convention uses registers RCX, RDX, R8, R9 for the first four integer or 
# pointer arguments (in that order), and XMM0, XMM1, XMM2, XMM3 are used for floating point arguments. 
# Additional arguments are pushed onto the stack (right to left). Integer return values (similar to x86)
# are returned in RAX if 64 bits or less. Floating point return values are returned in XMM0. Parameters
# less than 64 bits long are not zero extended; the high bits are not zeroed.
#
#endregion
#region PROLOG
#---------------------------------------------------------------------
	sub         rsp, 8*8
	mov         qword ptr [rsp+0*8], r15
	mov         qword ptr [rsp+1*8], r14
	mov         qword ptr [rsp+2*8], r13
	mov         qword ptr [rsp+3*8], r12
	mov         qword ptr [rsp+4*8], rbx

	mov         qword ptr [rsp+5*8], rdi
	mov         qword ptr [rsp+6*8], rsi
	mov         qword ptr [rsp+7*8], rbp
#endregion PROLOG:
#region PAYLOAD
#---------------------------------------------------------------------
#	int			3

	mov			r15,	rdx
	imul		r15,	r8
	imul		r15,	r9

	test		r15,	r15
	jz			EPILOG

.align 16
MY_LOOP: 
	dec			r15
	mov			dword ptr [rcx + 4*r15], r15d
	jnz			MY_LOOP

#endregion payload
#region EPILOG
#---------------------------------------------------------------------
EPILOG: 
	mov         r15, qword ptr [rsp+0*8]
	mov         r14, qword ptr [rsp+1*8]
	mov         r13, qword ptr [rsp+2*8]
	mov         r12, qword ptr [rsp+3*8]
	mov         rbx, qword ptr [rsp+4*8]
	mov         rdi, qword ptr [rsp+5*8]
	mov         rsi, qword ptr [rsp+6*8]
	mov         rbp, qword ptr [rsp+7*8]
	add         rsp, 8*8
	ret
#endregion

.att_syntax
