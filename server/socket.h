#ifndef SOCKET_H_
#define SOCKET_H_

#include <stdio.h>
#include <stdlib.h>
#include <winsock.h>
#include <io.h>

#define socket_t SOCKET

/**
* Prints out error message and exits.
*/
void error_exit(char *error_message);

/**
* Init Winsock and create a socket (e.g. TCP or UDP)
* The initialized socket is returned
*/
int create_socket(int af, int type, int protocol);

/**
* Binds the socket to the specified port.
*/
void bind_socket(socket_t *sock, unsigned long adress, unsigned short port);

/**
* Listen on the given socket
*/
void listen_socket(socket_t *sock);

/**
* Accept a connection on the given socket
* and transfer it to the given new_socket.
* socket can be used for receiving further
* connections.
*/
void accept_socket(socket_t *socket, socket_t *new_socket);

/**
* Sends the given data using TCP.
*/
void TCP_send(socket_t *sock, const char *data, size_t size);

/**
* Receive an answer on the given socket using TCP.
* The answer is stored in data with th length
* size.
* Returns true if successful, false otherwise.
*/
bool TCP_recv_answ(socket_t *sock, char *data, size_t size);

/**
* Sends the given data with the given length
* on the given scoket to the given address
* using UDP.
*/
void UDP_send(socket_t *sock, char *data, size_t size, sockaddr_in* addr_to);

/**
* Receives data with the given length on the given
* socket using UDP. The received data is stored in
* the data variable. The source of the package is
* stored in addr_from
*/
void UDP_recv(socket_t *sock, char *data, size_t size, sockaddr_in* addr_from);

/**
* Close socket.
*/
void close_socket(socket_t *sock);

/**
* Cleanup Winsock
*/
void cleanup(void);

#endif
