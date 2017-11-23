#!/usr/bin/env python3

import socket
import json
import numpy
import argparse
import cv2
sock = socket.socket()
port = 9090
sock.bind(('', port))
sock.listen(1)
conn, addr = sock.accept()

print ('connected:', addr)

while True:
	data = conn.recv(1024)
	if data:
		d=json.loads(data)
		conn.send(bytes(d["type"],'utf-8'))
		if d["type"]=="basket":
			conn.send(bytes(d["products"]["name"],'utf-8'))
			conn.send(bytes(str(d["totalPrice"]),'utf-8'))
		elif d["type"]=="image":
			conn.send(bytes(str(d["imageBase64"]),'utf-8'))
conn.close()