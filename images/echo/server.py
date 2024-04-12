import socket
import threading
import sys

RECV_SIZE = 65536
SOCKET_TIMEOUT = .5


def really_recv(sock: socket.socket) -> bytes:
    """Receives bytes from a socket until a timeout expires."""
    result: bytes = b""
    try:
        while b := sock.recv(RECV_SIZE):
            result += b
    except (TimeoutError, ConnectionResetError):
        pass
    return result


def handle_connection(client_sock: socket.socket, _client_address: tuple[str, int]) -> None:
    client_sock.settimeout(SOCKET_TIMEOUT)
    try:
        client_sock.sendall(b"220 echo\r\n")
    except ConnectionResetError:
        pass
    while payload := really_recv(client_sock):
        print(f"I received {payload!r}", file=sys.stderr)
        try:
            if payload.lstrip()[:5].rstrip().upper() == b"DATA":
                client_sock.sendall(b"354\r\n")
            else:
                client_sock.sendall(b"250\r\n")
        except ConnectionResetError:
            pass
    client_sock.close()


def main() -> None:
    """Serve"""
    server_sock: socket.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_sock.bind(("0.0.0.0", 25))
    server_sock.listen()
    while True:
        t: threading.Thread = threading.Thread(target=handle_connection, args=(*server_sock.accept(),))
        t.start()

if __name__ == "__main__":
    main()
