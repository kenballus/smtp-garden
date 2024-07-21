"""
Version 1.2, handles SIGTERM gracefully, with async routines -mss
Version 1.1, prints peer identification info -mss 6/10/2024
Version 1.0, by bk (original)
"""

import asyncio
import signal
import sys

RECV_SIZE = 65536

async def handle_connection(reader, writer):
    writer.write(b"220 echo\r\n")
    await writer.drain()
    while True:
        data = await reader.read(RECV_SIZE)
        if not data:
            break
        peer_host, peer_port = writer.get_extra_info('peername')
        print(f"Received from {peer_host}:{peer_port}: {data!r}")
        sys.stdout.flush()
        response = b"354\r\n" if data.lstrip()[:5].rstrip().upper() == b"DATA" else b"250\r\n"
        writer.write(response)
        await writer.drain()
    writer.close()
    await writer.wait_closed()

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
