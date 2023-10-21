SYS_WRITE equ 1
SYS_CLOSE equ 3
SYS_EXIT equ 60

SYS_SOCKET equ 41
SYS_CONNECT equ 42
SYS_SEND equ 44
SYS_RECV equ 45

AF_INET equ 2
SOCK_STREAM equ 1

STDIN equ 0
STDOUT equ 1


%macro exit 1
	mov rax, SYS_EXIT
	mov rdi, %1
	syscall
%endmacro

%macro print 1
	mov rax, %1
	call _print
%endmacro


%define CRLF 13, 10



%define PATH		"/hello.html"
%define SERVER_IP	"127.0.0.1"

section .data
	socket_err_msg:	db "Error creating socket", 10, 0
	msg_conn_err:	db "Error connecting to server", 10, 0
	msg_send_err:	db "Error sending data", 10, 0

	http_request:	db "GET ", PATH, " HTTP/1.1", CRLF
					db "Host: ", SERVER_IP, CRLF
					db "Connection: close", CRLF
					db "User-Agent: ASM HTTP Client", CRLF
					db "Accept: text/*", CRLF
					db CRLF, 0
	
	server_addr:							; 16 bytes
		sa_family		dw AF_INET			; 2 bytes
		remote_port 	dw 	0x401f			; 2 bytes		8000 in little endian
		remote_ip		dd 0x0100007F		; 4 bytes		127.0.0,1 in little endian
											;				the docs state that the address should be in network byte order which is big endian though
											; 				but it works, and that's all that matters :)

		zero			dd 0, 0				; 8 bytes		padding



section .bss
	response:		resb 1024*1024*1	; 1 MB
	socket_fd:		resb 8				; 8 bytes


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
	jle _socket_err					; If rax =< 0, there is an error

	mov [socket_fd], rax			; Store the socket file descriptor

_connect:
	mov rax, SYS_CONNECT
	mov rdi, [socket_fd]
	mov rsi, server_addr			; 16 bytes
	mov rdx, 16						; size of server_addr
	syscall

	cmp rax, 0
	jl _conn_err

_send:
	mov rax, http_request
	call _strlen

	mov rax, SYS_SEND
	mov rdi, qword [socket_fd]
	mov rsi, http_request
	mov rdx, rbx
	syscall

	cmp rax, 0
	jl _send_err

_recv:
	mov rax, SYS_RECV
	mov rdi, qword [socket_fd]
	mov rsi, response
	mov rdx, 1024*1024*1
	syscall
	
_print_response:
	mov rax, response
.header_loop:
	inc rax
	; if byte is 10 and next byte is 13, then add 3 and we are are at the beginning of the body
	cmp byte [rax], 10
	jne .header_loop
	cmp byte [rax+1], 13
	jne .header_loop

	add rax, 3
	call _print


_close:
	mov rax, SYS_CLOSE
	mov rdi, qword [socket_fd]
	syscall

_exit:
	exit 0



;
; Error handling
;
_socket_err:
	print socket_err_msg
	exit 1

_conn_err:
	print msg_conn_err
	exit 1

_send_err:
	print msg_send_err
	exit 1




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


