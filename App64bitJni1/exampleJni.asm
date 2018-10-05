BITS		64
ALIGN		8, nop

;#region JNI macros
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%macro GetArrayLength 0
	sub		rsp,	4*8
	mov		rbx,	[rcx]
	call	qword [rbx+8*171]	; call getArrayLength(JNIEnv, J_MS_OUT)
	add		rsp,	4*8
%endmacro
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%macro GetIntArrayElements 0
	sub		rsp,	4*8
	mov		rbx,	[rcx]
	call	qword [rbx+8*187]	; call GETIntArrayElements(JNIEnv, JIntArrayPTR, NULL) returns *carray in eax
	add		rsp,	4*8
%endmacro
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%macro ReleaseIntArrayElements 0
	sub		rsp,	4*8
	mov		rbx,	[rcx]
	call	qword [rbx+8*195]	; call ReleaseIntArrayElements(JNIEnv, JIntArrayPTR, CArrayPTR, 0)
	add		rsp,	4*8
%endmacro
;#endregion macros
;#region Java Wrapper for the C method testCode
;---------------------------------------------------------------------
GLOBAL Java_JniTest1_testCode
Java_JniTest1_testCode: ; proc JNIEnv:QWORD, self:QWORD, DATA_J:QWORD, NITEMS1_J:QWORD, NITEMS2_J: QWORD, NITEMS3_J: QWORD; 

	; params
	%define JNIEnv			qword [rbp+2*8]
	%define self			qword [rbp+3*8]
	%define DATA_J			qword [rbp+4*8]
	%define NITEMS1_J		qword [rbp+5*8]
	%define NITEMS2_J		qword [rbp+6*8]
	%define NITEMS3_J		qword [rbp+7*8]
	%define PARAM_SIZE		7*8
	;----------------------------------------------------------------
	; local variables
	%define DATA_C			qword [rbp-1*8]
	%define	DATA_C_SIZE		qword [rbp-2*8]
	%define	NITEMS1_C		qword [rbp-3*8]
	%define	NITEMS2_C		qword [rbp-4*8]
	%define	NITEMS3_C		qword [rbp-5*8]
	%define	RESULT			qword [rbp-6*8]
	
	%define LOCAL_VAR_SIZE	6*8
	;----------------------------------------------------------------
	int		3

	push	rbp
	mov		rbp,	rsp
	sub		rsp,	LOCAL_VAR_SIZE
	;----------------------------------------------------------------
	; save params as locals, in case the caller had not done that
	mov		JNIEnv,			rcx
;	mov		self,			rdx		; class is static, no need for self
	mov		DATA_J,			r8
	mov		NITEMS1_J,		r9


	;----------------------------------------------------------------
	mov		rcx,	JNIEnv			; first param
	mov		rdx,	DATA_J			; second param
	xor		r8,		r8				; third param
	GetIntArrayElements
	mov		qword DATA_C, rax
	;----------------------------------------------------------------
	mov		rcx,	JNIEnv			; first param
	mov		rdx,	DATA_J			; second param
	GetArrayLength
	mov		qword DATA_C_SIZE, rax
	;----------------------------------------------------------------
	
	mov		rax, NITEMS1_C
	mov		NITEMS1_J, rax
	mov		rax, NITEMS2_C
	mov		NITEMS2_J, rax
	mov		rax, NITEMS3_J
	mov		NITEMS3_C, rax


	mov		r9,		NITEMS3_C		; fourth param
	push	r9
;	mov		[rsp+4*8],	r9
	
	mov		r8,		NITEMS2_C		; third param
	push	r8
;	mov		[rsp+3*8],	r8
	
	mov		rdx,	NITEMS1_C		; second param
	push	rdx
;	mov		[rsp+2*8],	rdx
	
	mov		rcx,	DATA_C		; first param
	push	rcx
;	mov		[rsp+1*8],	rcx
	
	call	testCode			;rcx <= data; rdx <= nItems1; r8 <= nItems2; r9 <= nItems3
	mov		RESULT, rax	; store result of testCode
	add		rsp, 4*8

	;----------------------------------------------------------------
	mov		rcx,	JNIEnv		; first param
	mov		rdx,	DATA_J		; second param
	mov		r8,		DATA_C		; third param
	xor		r9,		r9			; fourth param; 0=update DATA_J; 2=do not update DATA_J; 
	ReleaseIntArrayElements
	;----------------------------------------------------------------
	mov		rax,	RESULT	; restore the return value for getResults in eax
	mov		rsp,	rbp
	pop		rbp
	ret		PARAM_SIZE
;#endregion
;#region testCode

testCode:
global testCode

; extern "C" void testCode(
;	unsigned long * const data, 
;	const unsigned long long nItems1, 
;	const unsigned long long nItems2, 
;	const unsigned long long nItems3)
;
; rcx <= data
; rdx <= nItems1
; r8 <= nItems2
; r9 <= nItems3

; The Microsoft x64 calling convention uses registers RCX, RDX, R8, R9 for the first four integer or 
; pointer arguments (in that order), and XMM0, XMM1, XMM2, XMM3 are used for floating point arguments. 
; Additional arguments are pushed onto the stack (right to left). Integer return values (similar to x86)
; are returned in RAX if 64 bits or less. Floating point return values are returned in XMM0. Parameters
; less than 64 bits long are not zero extended; the high bits are not zeroed.
;
;#region PROLOG
;---------------------------------------------------------------------
	sub         rsp, 8*8
	mov         qword [rsp+0*8], r15
	mov         qword [rsp+1*8], r14
	mov         qword [rsp+2*8], r13
	mov         qword [rsp+3*8], r12
	mov         qword [rsp+4*8], rbx

	mov         qword [rsp+5*8], rdi
	mov         qword [rsp+6*8], rsi
	mov         qword [rsp+7*8], rbp
;#endregion PROLOG
;#region PAYLOAD
;---------------------------------------------------------------------
;	int			3

	mov			r15,	rdx
	imul		r15,	r8
	imul		r15,	r9

	test		r15,	r15
	jz			EPILOG

align 16
MY_LOOP: 
	dec			r15
	mov			dword [rcx + 4*r15], r15d
	jnz			MY_LOOP

;#endregion PAYLOAD
;#region EPILOG
;---------------------------------------------------------------------
EPILOG: 
	mov         r15, qword [rsp+0*8]
	mov         r14, qword [rsp+1*8]
	mov         r13, qword [rsp+2*8]
	mov         r12, qword [rsp+3*8]
	mov         rbx, qword [rsp+4*8]
	mov         rdi, qword [rsp+5*8]
	mov         rsi, qword [rsp+6*8]
	mov         rbp, qword [rsp+7*8]
	add         rsp, 8*8
	ret
;#endregion testCode
;#endregion testCode
