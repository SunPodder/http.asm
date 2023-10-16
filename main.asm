%include "linux.asm"
%include "print.asm"

%define CRLF 13, 10

section .data
	err_msg:		db "Error!", 10, 0

	http_request:	db "GET / HTTP/1.1", CRLF
					db "Host: 127.0.0.1", CRLF
					db "Connection: close", CRLF
					db "User-Agent: ASM HTTP Client", CRLF
					db "Accept: */*", CRLF
					db "Accept-Language: en-US", CRLF
					db "Accept-Charset: utf-8", CRLF
					db CRLF, 0
	
	server_addr:							; 8 bytes
		sa_family		dw AF_INET			; 2 bytes
		remote_ip		dd 0x0100007F		; 4 bytes		127.0.0.1 in little endian
		remote_port 	dw 0x401F			; 2 bytes		8000 in little endian


section .bss
	response:		resb 1024*1024*1	; 1 MB
	socket_fd:		resq 1				; 8 bytes


section .text
	global _start

_start:

_socket:
	mov rax, SYS_SOCKET
	mov rdi, AF_INET
	mov rsi, SOCK_STREAM
	mov rdx, 0						; protocol
	syscall

	cmp rax, 0
	jle _error						; If rax < 0, jump to _error

	mov qword [socket_fd], rax		; Store the socket file descriptor

_connect:
	mov rax, SYS_CONNECT
	mov rdi, qword [socket_fd]		; 8 bytes
	lea rsi, [server_addr]			; 8 bytes
	mov rdx, 16
	syscall

	cmp rax, 0
	jle _error

_send:
	mov rax, http_request
	call _strlen

	mov rax, SYS_WRITE
	mov rdi, qword [socket_fd]
	mov rsi, http_request
	mov rdx, rbx

	syscall


_close:
	mov rax, SYS_CLOSE
	mov rdi, qword [socket_fd]
	syscall


_exit:
	exit 0

_error:
	print err_msg
	exit 1

