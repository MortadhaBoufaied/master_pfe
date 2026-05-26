import socket
import ssl

host = 'dpg-d83f2av7f7vs7392hj90-a.frankfurt-postgres.render.com'
port = 5432

try:
    with socket.create_connection((host, port), timeout=10) as sock:
        print('tcp connected')
        ctx = ssl.create_default_context()
        with ctx.wrap_socket(sock, server_hostname=host) as ssock:
            print('ssl version:', ssock.version())
            print('cipher:', ssock.cipher())
except Exception as e:
    print('ERROR', repr(e))
