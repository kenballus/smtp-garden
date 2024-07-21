#!/usr/bin/python3
"""
sendmsg v2
Send contents of file $1 to $2:$3[=25]

Arguments to consider adding:
-s --short          mask decorators from stdout (i.e. "DATA\r\n" instead of "[sendmsg]: b'DATA\r\n'")
-S --silent         mask all output
-R --mask-rx        mask received data from stdout
-T --mask-tx        mask sent data from stdout

Version 2: improved escape sequence handling
Version 1: limited escape sequence handling (\r, \n only)

About message formatting:
-Input files are assumed to be text files with line breaks of 0x0A for readability,
 but these line terminators will be ignored in the sending of byte data.
-Windows-style, i.e. \r\n, will not work as expected. Use Linux convention.
-Escaped characters will be interpreted as such, using codes.escape_decode(). i.e.:
 '\r' and '\n' literals in the input file become carriage return and newline.
 '\x41' becomes 'A', '\t' is ASCII tab, etc.
-codecs.escape_decode() is an undocumented Python function, so proceed with caution!
-If you do not put at least a '\n' token at the end of every line, the mail server will probably
 get confused and not recognize EOL, and a timeout exception will be caught.
"""

import socket
import sys
import codecs

mail_port = 25

def usage(complaint = None):
    usage_str = f"sendmsg.py payload.txt server [port|{mail_port}]\n"
    if complaint != None:
        print(complaint)
    sys.exit(usage_str)

def enough_args():
    if len(sys.argv) < 3 or sys.argv[1] == "--help" or sys.argv[1] == "-h":
        return False
    return True

def validate_port(port = "notNone"): # pre-empt a None-related exception
    complain_badport = f"Error: {port} is not a number 1-65535"
    if not port.isdigit():
        usage(complain_badport)
    portnum = int(port)
    if portnum < 1 or portnum > 65535:
        usage(complain_badport)
    return portnum

def sendmsg(filename, servername, port):
    print(f"Sending {filename} to {servername}:{port} ...")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(5)
        s.connect((servername, port))
        try:
            banner = s.recv(1024)
        except socket.timeout:
            sys.exit("No SMTP banner received within timeout period, quitting.")
        print(f"Received [{s.getpeername()}]: {banner!r}")
        s.settimeout(1)
        with open(filename, "r") as email:
            for line in email:
                linebytes = codecs.escape_decode(bytes(line[0:-1], "utf-8"))[0]
                print(f"Sending [{s.getsockname()}]: {linebytes!r}")
                s.sendall(linebytes)
                try:
                    reply = s.recv(1024)
                except socket.timeout:
                    continue
                print(f"Received [{s.getpeername()}]: {reply!r}")

if __name__ == "__main__":
    if not enough_args():
        usage()
    if len(sys.argv) > 3:
        mail_port = validate_port(sys.argv[3])
    sendmsg(sys.argv[1], sys.argv[2], mail_port) # filename, servername, port
