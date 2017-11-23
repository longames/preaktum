#!/usr/bin/env python
#-*- condig: utf-8 -*-
import pymysql
import json
db = pymysql.connect(host='localhost',
                             user='la1n',
                             password='top4ek',
                             db='shop',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor,
                             use_unicode=True)
cur=db.cursor()
def select_from_id (id_rec):
	cur.execute("""SELECT * FROM products WHERE id = %s""",(id_rec))
	data = cur.fetchone()
	jdata = json.dumps(data, ensure_ascii=False)
	return(jdata)
select_from_id(1)