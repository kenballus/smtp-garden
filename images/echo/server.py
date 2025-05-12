"""
SMTP Garden - Python Echo Server

Version 1.5.1, -EHLO disabled pending further investigation, as it breaks msmtp
Version 1.5,   -replies with ESMTP codes if it receives an "EHLO".
               -set global EHLO_announce to False to disable
Version 1.4,   -replies with minimum 4 bytes (instead of 3) to appease finicky clients
               -generate_response method drafted in comment block -mss 8/27/2024
Version 1.3,   -handles ConnectionResetError, commonly caused by MTA disconnecting abruptly
Version 1.2,   -async routines
               -handles SIGTERM gracefully
Version 1.1,   -prints peer identification info -mss 6/10/2024
Version 1.0,   -by bk (original)
"""

import asyncio
import signal
import sys

EHLO_announce = False
RECV_SIZE = 65536

"""
# Alternate response generator, if higher fidelity to normal behavior is needed
# (<CR><LF>.<CR><LF> detection is not ideal)
def generate_response(client_bytes, is_datamode):
    EHLO_block = b"250-echo.smtp.garden\r\n" + \
                 b"250-PIPELINING\r\n" + \
                 b"250-SIZE " + str(RECV_SIZE).encode('ascii') + b"\r\n" + \
                 b"250-VRFY\r\n" + \
                 b"250-8BITMIME\r\n" + \
                 b"250 CHUNKING"
    if is_datamode:
        if client_bytes == b".":
            return b"250 Ok", False
        else:
            return b"", True
    if client_bytes == b"DATA":
        return b"354 Send data\r\n", True
    elif client_bytes == b"QUIT":
        return b"221 Bye\r\n", False
    elif client_bytes.lstrip()[:4].upper() == b"EHLO":
        return EHLO_block, False
    else:
        return b"250 Ok", False
"""

async def handle_connection(reader, writer):
    EHLO_block = b"250-echo.smtp.garden\r\n" + \
                 b"250-PIPELINING\r\n" + \
                 b"250-SIZE " + str(RECV_SIZE).encode('ascii') + b"\r\n" + \
                 b"250-VRFY\r\n" + \
                 b"250-8BITMIME\r\n" + \
                 b"250 CHUNKING\r\n"
    try:
        writer.write(b"220 echo ESMTP\r\n")
        await writer.drain()
#        is_datamode = False
        while True:
            data = await reader.read(RECV_SIZE)
            if not data:
                break
            peer_host, peer_port = writer.get_extra_info('peername')
            print(f"Received from {peer_host}:{peer_port}: {data!r}")
            sys.stdout.flush()
#            response, is_datamode = generate_response(data.lstrip()[:5].rstrip().upper(), is_datamode)
            response = b"354 \r\n" if data.lstrip()[:5].rstrip().upper() == b"DATA" else \
                       EHLO_block if data.lstrip()[:4].upper() == b"EHLO" and EHLO_announce else \
                       b"250 \r\n"
            writer.write(response)
            await writer.drain()
        writer.close()
        Hawait writer.wait_closed()
    except ConnectionResetError:
        print("ConnectionResetError caught: Connection reset by peer (premature disconnection)")

async def shutdown(loop, server):
    server.close()
    await server.wait_closed()
    tasks = [t for t in asyncio.all_tasks() if t is not asyncio.current_task()]
    for task in tasks:
        task.cancel()
    await asyncio.gather(*tasks, return_exceptions=True)
    loop.stop()

def stop_handler(loop, server):
    asyncio.ensure_future(shutdown(loop, server))

async def main():
    server = await asyncio.start_server(handle_connection, '0.0.0.0', 25)
    loop = asyncio.get_running_loop()
    loop.add_signal_handler(signal.SIGTERM, stop_handler, loop, server)
    loop.add_signal_handler(signal.SIGINT, stop_handler, loop, server)
    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except asyncio.CancelledError:
        print("echo server closed.")

