BITS		32
ALIGN		4, nop

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
	%define JNIEnv			[ebp+2*4]
	%define self			[ebp+3*4]
	%define DATA_J			[ebp+4*4]
	%define NITEMS1_J		[ebp+5*4]
	%define NITEMS2_J		[ebp+6*4]
	%define NITEMS3_J		[ebp+7*4]
	%define PARAM_SIZE		6*4
	;----------------------------------------------------------------
	; local variables
	%define DATA_C			[ebp-1*4]
	%define	DATA_C_SIZE		[ebp-2*4]
	%define	NITEMS1_C		[ebp-3*4]
	%define	NITEMS2_C		[ebp-4*4]
	%define	NITEMS3_C		[ebp-5*4]
	%define	RESULT			[ebp-6*4]
	
	%define LOCAL_VAR_SIZE	6*4
	;----------------------------------------------------------------
	int		3

	push	ebp
	mov		ebp,	esp
	sub		esp,	LOCAL_VAR_SIZE
	;----------------------------------------------------------------
	; save params as locals, in case the caller had not done that
	mov		JNIEnv,			rcx
;	mov		self,			rdx		; class is static, no need for self
	mov		DATA_J,			r8
	mov		NITEMS1_J,		r9


	;----------------------------------------------------------------
	mov		edx,	JNIEnv
	mov		ebx,	[edx]
	push	0						; NULL = 0
	push	dword DATA_J			; parameters for
	push	edx						; first param: JNIEnv
	call	dword near [ebx+4*187]	; call GETIntArrayElements(JNIEnv, JIntArrayPTR, NULL) returns *carray in eax
	mov		dword DATA_C, eax
	;----------------------------------------------------------------
	;mov		rcx,	JNIEnv			; first param
	;mov		rdx,	DATA_J			; second param
	;xor		r8,		r8				; third param
	;GetIntArrayElements
	;mov		qword DATA_C, rax
	;----------------------------------------------------------------
	mov		edx,	JNIEnv
	mov		ebx,	[edx]
	push	dword DATA_J				; parameters for
	push	edx							; first param: JNIEnv
	call	dword near [ebx+4*171]		; call getLength(JNIEnv, JIntArrayPTR) returns *carray in eax
	mov		dword DATA_C_SIZE, eax
	;----------------------------------------------------------------
	;mov		rcx,	JNIEnv			; first param
	;mov		rdx,	DATA_J			; second param
	;GetArrayLength
	;mov		qword DATA_C_SIZE, rax
	;----------------------------------------------------------------
	
	mov		eax, NITEMS1_J
	mov		NITEMS1_C, eax
	mov		eax, NITEMS2_J
	mov		NITEMS2_C, eax
	mov		eax, NITEMS3_J
	mov		NITEMS3_C, eax
	;----------------------------------------------------------------	
	push	dword NITEMS3_C		; fourth param
	push	dword NITEMS2_C
	push	dword NITEMS1_C
	push	dword DATA_C		; ; first param
	call	getResults			; getResults; C_MS_IN:DWORD, C_MS_IN_SIZE:DWORD, C_MS_OUT:DWORD, C_MS_OUT_SIZE:DWORD, C_TRACER:DWORD, 	mov		RESULT, rax	; store result of testCode
	;----------------------------------------------------------------
	mov		edx,	JNIEnv
	mov		ebx,	[edx]
	push	0					; mode: copy back and free the carray buffer; 0 is for normal; 2 is for abort;
	push	dword DATA_C		; *carray
	push	dword DATA_J		; *jarray 
	push	edx					; first param: JNIEnv
	call	dword [ebx+4*195]	; call ReleaseIntArrayElements(JNIEnv, JIntArrayPTR, CArrayPTR, 0)
	;----------------------------------------------------------------
	;mov		rcx,	JNIEnv		; first param
	;mov		rdx,	DATA_J		; second param
	;mov		r8,		DATA_C		; third param
	;xor		r9,		r9			; fourth param; 0=update DATA_J; 2=do not update DATA_J; 
	;ReleaseIntArrayElements
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
	mov         qword [rsp+0*4], r15
	mov         qword [rsp+1*4], r14
	mov         qword [rsp+2*4], r13
	mov         qword [rsp+3*4], r12
	mov         qword [rsp+4*4], rbx

	mov         qword [rsp+5*4], rdi
	mov         qword [rsp+6*4], rsi
	mov         qword [rsp+7*4], rbp
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
