#!/usr/bin/python3
"""
sendmsg v3.1 - 20240731 mss

Version 3.1 - refactored multiple nested if-statements

$ ./sendmsg.py message_file [server|"localhost"] [port:"25"]

Send contents of message_file to sever:port

Arguments to consider adding:
-s --short          mask decorators from stdout
                   (i.e. "DATA\r\n" instead of "[sendmsg]: b'DATA\r\n'")
-S --silent         mask all output
-R --mask-rx        mask received data from stdout
-T --mask-tx        mask sent data from stdout

Version 3.1: fix potential bug printing peer reply in sendmsg() method
Version 3: assumes default value for host, if not specified.
           improved exception handling
Version 2: improved escape sequence handling
Version 1: limited escape sequence handling (\r, \n only)

Examples:
$ ./sendmsg.py payload.txt postfix 2501
$ ./sendmsg.py payload.txt 172.18.0.3 # assumes 172.18.0.3:25
$ ./sendmsg.py payload.txt postfix # assumes postfix:25
$ ./sendmsg.py payload.txt 2501 # assumes localhost:2501
$ ./sendmsg.py payload.txt # sends to localhost:25

Also accepts alternate IP forms:
$ ./sendmsg2.py testmsg.txt 2130706433 2504 # integer IP address, 127.0.0.1:2504
$ ./sendmsg2.py testmsg.txt 0177.0000.0000.0001 2504 # Octal IP address example
$ ./sendmsg2.py testmsg.txt 0x7F000001 2504 # hexadecimal IP address example


About message formatting:
-Input files are assumed to be text files with line breaks of 0x0A for
 readability, but these line terminators will be ignored in the sending of
 byte data.
-Windows-style, i.e. \r\n, will not work as expected. Use Linux convention.
-Escaped characters will be interpreted as such, using codes.escape_decode().
  i.e.: '\r' and '\n' literals in the input file become carriage return and
  newline. '\x41' becomes 'A', '\t' is ASCII tab, etc.
-codecs.escape_decode() is an undocumented Python function, so proceed with
 caution!
-If you do not put at least a '\n' token at the end of every line, the mail
 server will probably  get confused and not recognize EOL, and a timeout
 exception will be caught.
"""

import socket
import sys
import codecs
from os.path import exists as file_exists

ESTABLISH_FAIL = False
ESTABLISH_OK   = True


default_servername = "localhost"
default_mail_port = 25
mail_port = default_mail_port
servername = default_servername


""" Argument handling """
def usage(complaint = None):
    usage_str = f'Usage: sendmsg.py payload.txt [server|"{servername}"] [port|"{default_mail_port}"]\n'
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

def reconcile_single_host_arg(given_arg, default_host, mail_port):
    if mail_port == 0:
        mail_port = 25
        return given_arg, mail_port
    else:
        return default_host, mail_port


""" Socket handling """
def print_if_notNone(peer_name, reply):
    if reply != None:
        print(f"Received [{peer_name}]: {reply!r}")
    else:
        print("No reply from {peer_name} (Something may have gone wrong)")

def send_email_to_socket(email, s):
    peer_name = s.getpeername()
    sock_name = s.getsockname()
    for line in email:
        linebytes = codecs.escape_decode(bytes(line[0:-1], "utf-8"))[0]
        print(f"Sending [{sock_name}]: {linebytes!r}")
        s.sendall(linebytes)
        reply = None
        try:
            reply = s.recv(1024)
        except socket.timeout:
            # Note: peer timeout is normal behavior during DATA transmission
            #print("Socket timeout, peer {peer_name}")
            continue
        else:
            print_if_notNone(peer_name, reply)

def establish_conn(s, servername, port):
    s.settimeout(5)
    try:
        s.connect((servername, port))
    except socket.gaierror:
        print(f"Unable to identify host {servername}.")
        return ESTABLISH_FAIL
    except ConnectionRefusedError:
        print(f"Connection refused by {servername}:{port}")
        return ESTABLISH_FAIL
    return ESTABLISH_OK

def get_banner(s):
    try:
        banner = s.recv(1024)
    except socket.timeout:
        sys.exit("No SMTP banner received within timeout period, quitting.")
    return banner

def sendmsg(filename, servername, port):
    print(f"==================== Sending {filename} to {servername}:{port} =====================")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        sock_ok = establish_conn(s, servername, port)
        if not sock_ok:
            return
        banner = get_banner(s)
        print(f"Received [{s.getpeername()}]: {banner!r}")
        s.settimeout(0.05)
        with open(filename, "r") as email:
            send_email_to_socket(email, s)


""" Main """
if __name__ == "__main__":
    if not enough_args():
        usage()
    arglen = len(sys.argv)

    if arglen == 3:
        # last arg is either a servername or port
        mail_port = validate_port(sys.argv[2])
        servername, mail_port = reconcile_single_host_arg(sys.argv[2], servername, mail_port)
    elif arglen == 4:
        mail_port = validate_port(sys.argv[3])
    if mail_port == 0: # should only happen here if arglen==4 and mail_port is invalid
        usage(f'Error: Port "{sys.argv[3]}" is not a number 1-65535')

    filename = sys.argv[1]
    if file_exists(filename):
        sendmsg(filename, servername, mail_port)
    else:
        usage(f"File {filename} not found")
