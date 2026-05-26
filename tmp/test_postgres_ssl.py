import socket

host = 'dpg-d83f2av7f7vs7392hj90-a.frankfurt-postgres.render.com'
port = 5432

try:
    with socket.create_connection((host, port), timeout=10) as sock:
        print('connected to', host, port)
        # SSLRequest packet: length 8, protocol 80877103
        sock.sendall((8).to_bytes(4, byteorder='big') + (80877103).to_bytes(4, byteorder='big'))
        resp = sock.recv(1)
        print('response bytes:', resp)
except Exception as e:
    print('ERROR', repr(e))
