#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from flask import Flask
import json
from sqldb import select_from_id
app = Flask(__name__)


@app.route("/<data>", methods=['GET'])
def index(data):
	while data:
		if not data:
			break
		print (data)
		#data = str(data, 'utf-8')
		print (data)
		jdata = json.loads(data)
		print (jdata)
		return(bytes(select_from_id(jdata), 'utf-8'))

if __name__ == "__main__":
	app.run(host='0.0.0.0', port=4567)
