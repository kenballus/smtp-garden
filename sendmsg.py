#!/usr/bin/python3
"""
sendmsg v3 - 20240730 mss

Send contents of file $1 to $2[=localhost]:$3[=25]

Arguments to consider adding:
-s --short          mask decorators from stdout (i.e. "DATA\r\n" instead of "[sendmsg]: b'DATA\r\n'")
-S --silent         mask all output
-R --mask-rx        mask received data from stdout
-T --mask-tx        mask sent data from stdout

Version 3: assumes default value for host, if not specified
           improved exception handling
Version 2: improved escape sequence handling
Version 1: limited escape sequence handling (\r, \n only)

Examples:
$ ./sendmsg.py payload.txt postfix 2501
$ ./sendmsg.py payload.txt 172.18.0.3 # assumes 172.18.0.3:25
$ ./sendmsg.py payload.txt postfix # assumes postfix:25
$ ./sendmsg.py payload.txt 2501 # assumes localhost:2501
$ ./sendmsg.py payload.txt # sends to localhost:25

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
from os.path import exists as file_exists

mail_port = 25
servername = "localhost"


def usage(complaint = None):
    usage_str = f'Usage: sendmsg.py payload.txt [server|"{servername}"] [port|"{mail_port}"]\n'
    if complaint != None:
        print(complaint)
    sys.exit(usage_str)

def enough_args():
    if len(sys.argv) < 2 or len(sys.argv) > 4 or sys.argv[1] == "--help" or sys.argv[1] == "-h":
        return False
    return True

def validate_port(port = "notNone"): # pre-empt a None-related exception
    if not port.isdigit():
        return 0 #
    portnum = int(port)
    if portnum < 1 or portnum > 65535:
        return 0 #
    return portnum

def sendmsg(filename, servername, port):
    print(f"Sending {filename} to {servername}:{port} ...")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(5)
        try:
            s.connect((servername, port))
        except socket.gaierror:
            print(f"Unable to identify host {servername}.")
            return
        except ConnectionRefusedError:
            print(f"Connection refused by {servername}:{port}")
            return
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
    arglen = len(sys.argv)
    if arglen == 3:
        # last arg is either a servername or port
        mail_port = validate_port(sys.argv[2])
        if mail_port == 0:
            mail_port = 25
            servername = sys.argv[2]
    elif arglen == 4:
        mail_port = validate_port(sys.argv[3])
        if mail_port == 0:
            usage(f"Error: {sys.argv[3]} is not a number 1-65535")
    filename = sys.argv[1]
    if file_exists(filename):
        sendmsg(filename, servername, mail_port)
    else:
        usage(f"File {filename} not found")
