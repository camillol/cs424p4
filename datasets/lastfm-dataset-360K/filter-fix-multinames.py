#!/usr/bin/env python

def write_command(sqlf, lastid, lastnames):
	_, name = max((v,k) for k,v in lastnames.items())
	name = name.replace('\\', '\\\\').replace("'","''")
	sqlf.write("update artists set name='%s' where id=%d;\n" % (name, lastid))

with open("artid-namecount-artname-multinames.tsv") as multif:
	with open("artnamefix.sql", "w") as sqlf:
		lastid = None
		for line in multif:
			artid, namecount, artname = line.split('\t')
			artid = int(artid)
			artname = artname.strip()
			if artid != lastid:
				if lastid:
					write_command(sqlf, lastid, lastnames)
				lastid = artid
				lastnames = {}
			lastnames[artname] = namecount
		if lastid:
			write_command(sqlf, lastid, lastnames)

