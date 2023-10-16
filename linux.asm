SYS_READ equ 0
SYS_WRITE equ 1
SYS_OPEN equ 2
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
STDERR equ 2


%macro exit 1
	mov rax, SYS_EXIT
	mov rdi, %1
	syscall
%endmacro


