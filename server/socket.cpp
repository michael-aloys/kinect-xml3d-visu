#include "stdafx.h"
#include "socket.h"

#define socket_t SOCKET

/**
* Prints out error message and exits.
*/
void error_exit(char *error_message) {
	fprintf(stderr, "%s: %d\n", error_message, WSAGetLastError());
	exit(EXIT_FAILURE);
}

/**
* Init Winsock and create a socket (e.g. TCP or UDP)
* The initialized socket is returned
*/
int create_socket(int af, int type, int protocol) {
	socket_t sock;
	WORD wVersionRequested;
	WSADATA wsaData;
	wVersionRequested = MAKEWORD(1, 1);
	if (WSAStartup(wVersionRequested, &wsaData) != 0) {
		error_exit("An error occured while initializing Winsock.");
	}

	sock = socket(af, type, protocol);
	if (sock < 0) {
		error_exit("An error occured while creating the socket.");
	}
	return sock;
}

/**
* Binds the socket to the specified port.
*/
void bind_socket(socket_t *sock, unsigned long adress, unsigned short port) {
	struct sockaddr_in server;

	memset(&server, 0, sizeof(server));
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = htonl(adress);
	server.sin_port = htons(port);
	if (bind(*sock, (struct sockaddr*) &server, sizeof(server)) == SOCKET_ERROR) {
		error_exit("Could not bind the socket.");
	}
}

/**
* Listen on the given socket
*/
void listen_socket(socket_t *sock) {
	if (listen(*sock, 5) == SOCKET_ERROR) {
		error_exit("Could not listen on socket.");
	}
}

/**
* Accept a connection on the given socket
* and transfer it to the given new_socket.
* socket can be used for receiving further
* connections.
*/
void accept_socket(socket_t *socket, socket_t *new_socket){
	struct sockaddr_in client;
	int len = sizeof(client);

	*new_socket = accept(*socket, (struct sockaddr *)&client, &len);
	if (*new_socket == INVALID_SOCKET)
		error_exit("Error during accept.");
}

/**
 *  Sending data via TCP
 */
void TCP_send(socket_t *sock, const char *data, size_t size) {
	if (send(*sock, data, size, 0) == SOCKET_ERROR)
		error_exit("An error occured while sending the UDP data.");
}


/**
* Receive an answer on the given socket using TCP.
* The answer is stored in data with th length
* size.
* Returns true if successful, false otherwise.
*/
bool TCP_recv_answ(socket_t *sock, char *data, size_t size) {
	int len;
	len = recv(*sock, data, size, 0);
	if (len > 0 || len != SOCKET_ERROR) {
		return true;
	}
	else {
		return false;
	}
}

/**
* Sends the given data with the given length
* on the given scoket to the given address
* using UDP.
*/
void UDP_send(socket_t *sock, char *data, size_t size, sockaddr_in* addr_to){
	int result = sendto(*sock, data, size, 0, (struct sockaddr *) addr_to, sizeof(*addr_to));
	if (result == SOCKET_ERROR) {
		error_exit("An error occured while sending the UDP data.");
	}
}

/**
* Receives data with the given length on the given
* socket using UDP. The received data is stored in
* the data variable. The source of the package is
* stored in addr_from
*/
void UDP_recv(socket_t *sock, char *data, size_t size, sockaddr_in* addr_from){
	int len = sizeof(*addr_from);
	int n = recvfrom(*sock, data, size, 0, (struct sockaddr *) addr_from, &len);
	if (n == SOCKET_ERROR) {
		error_exit("An error occured while receiving data on UDP");
	}
}


/**
* Close socket.
*/
void close_socket(socket_t *sock){
	closesocket(*sock);
}

/**
* Cleanup Winsock
*/
void cleanup(void){
	WSACleanup();
}
