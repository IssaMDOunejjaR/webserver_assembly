SYS_WRITE equ 1
SYS_READ equ 0
SYS_EXIT equ 60
SYS_CLOSE equ 6
SYS_SOCKET equ 41
SYS_BIND equ 49
SYS_ACCEPT equ 43
SYS_LISTEN equ 50

AF_INET equ 2
INADDR_ANY equ 0
SOCK_STREAM equ 1
SOL_SOCKET equ 1
SOL_REUSEADDR equ 2
SOL_REUSEPORT equ 15

PORT equ 8080

%macro write 3
  mov rax, SYS_WRITE
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  syscall
%endmacro

%macro read 3
  mov rax, SYS_READ
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  syscall
%endmacro

%macro exit 1
  mov rax, SYS_EXIT
  mov rdi, %1
  syscall
%endmacro

%macro close 1
  mov rax, SYS_CLOSE
  mov rdi, %1
  syscall
%endmacro

; int socket(int domain, int type, int protocol);
%macro socket 3
  mov rax, SYS_SOCKET
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  syscall
%endmacro

; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
%macro bind 3
  mov rax, SYS_BIND
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  syscall
%endmacro

; int listen(int sockfd, int backlog);
%macro listen 2
  mov rax, SYS_LISTEN
  mov rdi, %1
  mov rsi, %2
  syscall
%endmacro

; int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
%macro accept 3
  mov rax, SYS_ACCEPT
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  syscall
%endmacro

; struc sockaddr_in
;   .sin_family dd 0; 16 bits
;   .sin_port ; 16 bits
;   .sin_addr
;   .sin_zero
; endstruc

section .text
  global _start

_start:
  ; Start Message
  write 1, msg, msg_len 

  ; Creating the socket
  write 1, socket_msg, socket_msg_len 
  socket AF_INET, SOCK_STREAM, 0
  cmp rax, 0
  jl _error
  mov [server_fd], rax
  write 1, ok_msg, ok_msg_len 
  
  ; Bind the socket
  write 1, bind_msg, bind_msg_len 
  mov word [sockaddr.sin_family], AF_INET
  mov word [sockaddr.sin_port], 23569
  mov dword [sockaddr.sin_addr], INADDR_ANY
  bind [server_fd], sockaddr.sin_family, sizeof_sockaddr
  cmp rax, 0
  jl _error
  write 1, ok_msg, ok_msg_len 

  ; Listen to connections
  write 1, listen_msg, listen_msg_len 
  listen [server_fd], 5
  cmp rax, 0
  jl _error
  write 1, ok_msg, ok_msg_len
  
  ; Start accepting requests
  write 1, accept_msg, accept_msg_len 
  jmp _accept

  exit 0

_accept:
  accept [server_fd], clientaddr.sin_family, sizeof_clientaddr
  cmp rax, 0
  jl _error

  mov [client_fd], rax 
  write [client_fd], hello_msg, hello_msg_len

  read [client_fd], client_msg, client_msg_len
  write 1, client_msg, client_msg_len
  
  jmp _accept

_error:
  write 2, error_msg, error_msg_len
  close [server_fd]
  close [client_fd]
  exit 1

section .data
  msg db "[INFO]: Start Web Server... ", 10
  msg_len equ $ - msg
  socket_msg db "[INFO]: Creating the socket... "
  socket_msg_len equ $ - socket_msg
  bind_msg db "[INFO]: Bind the socket... "
  bind_msg_len equ $ - bind_msg
  listen_msg db "[INFO]: Listen for connections... "
  listen_msg_len equ $ - listen_msg
  accept_msg db "[INFO]: Start accepting requests...", 10
  accept_msg_len equ $ - accept_msg
  hello_msg db "-- Hello from webserver with NASM --", 10
  hello_msg_len equ $ - hello_msg

  client_msg dq 0
  client_msg_len dq 0

  ok_msg db "Ok!", 10
  ok_msg_len equ $ - ok_msg

  error_msg db "Error!", 10
  error_msg_len equ $ - error_msg

  server_fd dq 0
  client_fd dq 0

  sockaddr.sin_family dw 0
  sockaddr.sin_port   dw 0
  sockaddr.sin_addr   dd 0
  sockaddr.sin_zero   dq 0
  sizeof_sockaddr equ $ - sockaddr.sin_family
  
  clientaddr.sin_family dw 0
  clientaddr.sin_port   dw 0
  clientaddr.sin_addr   dd 0
  clientaddr.sin_zero   dq 0
  sizeof_clientaddr     dd 0
