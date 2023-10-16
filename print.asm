%macro print 1
	mov rax, %1
	call _print
%endmacro

; @param rax - pointer to string
; @return rax - length of string
_strlen:
	xor rbx, rbx	; rbx - string length
.strLenLoop:
	inc rbx
	inc rax

	mov cl, [rax]	; cl - current char
	cmp cl, 0
	jne .strLenLoop

	mov rax, rbx	; return length
	ret


; @param rax - pointer to string
; @return rax - length of string
_print:
	push rax		; save string pointer
	call _strlen	; rax - length of string
	push rax

	mov rax, 1		; write syscall
	mov rdi, STDOUT
	pop rdx			; length
	pop rsi			; string pointer
	syscall
	mov rax, rbx	; return length
	ret

