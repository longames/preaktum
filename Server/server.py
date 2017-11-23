#!/usr/bin/env python3

import socket
import json
from sqldb import select_from_id
sock = socket.socket()
port = 9090
sock.bind(('127.0.0.1', port))
sock.listen(1)
conn, addr = sock.accept()

print ('connected:', addr)
while True:
	data = conn.recv(1024)
	if data:
		conn.send(bytes(select_from_id(data),'utf-8'))
conn.close()