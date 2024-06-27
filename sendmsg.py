#!/usr/bin/python3
"""
Send contents of file $1 to $2:$3[=25]

Arguments to consider adding:
-s --short          mask decorators from stdout (i.e. "DATA\r\n" instead of "[sendmsg]: b'DATA\r\n'")
-S --silent         mask all output
-R --mask-rx        mask received data from stdout
-T --mask-tx        mask sent data from stdout

About message formatting:
-Input files are assumed to be text files with line breaks of 0x0A for readability,
 but these line terminators will be ignored in the sending of byte data.
-When it is desired to send a \r (0x0D) or \n (0x0A), put literal '\r' or '\n' token(s)
 in the file (like you were writing a string for printf.)
-These tokens will be translated to 0x0D and 0x0A respectively, for sending, so you have
 granular control.
-If you do not put at least a '\n' token at the end of every line, the mail server will probably
 get confused and not recognize EOL, and a timeout exception will be caught.
-Use '\r' as desired for signaling end of DATA and/or fuzzing.
"""

import socket
import sys


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
    complain_badport = f"Error: {port} is not a number -65535"
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
        print(f"[{servername}]: {banner!r}")
        s.settimeout(1)
        with open(filename, "r") as email:
            for line in email:
                line = line[0:-1] # strip \n
                linebytes = line.replace("\\r","\r").replace("\\n","\n").encode()
                print(f"[sendmsg]: {linebytes!r}")
                s.sendall(linebytes)
                try:
                    reply = s.recv(1024)
                except socket.timeout:         
                    continue
                print(f"[{servername}]: {reply!r}")


if __name__ == "__main__":
    if not enough_args():
        usage()
    if len(sys.argv) > 3:
        mail_port = validate_port(sys.argv[3])
    sendmsg(sys.argv[1], sys.argv[2], mail_port) # filename, servername, port
