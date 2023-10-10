#include <asm-generic/socket.h>
#include <bits/sockaddr.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>

int main(void) {
  int server_fd;
  struct sockaddr_in test;

  if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket failed");
    exit(EXIT_FAILURE);
  }

  printf("sa_family_t: %ld\n",
         sizeof(sa_family_t));                      // 16 bits
  printf("in_port_t: %ld\n", sizeof(in_port_t));    // 16 bits
  printf("in_addr: %ld\n", sizeof(struct in_addr)); // 32 bits
  printf("char: %ld\n", sizeof(char));              // 32 bits

  return 0;
}
