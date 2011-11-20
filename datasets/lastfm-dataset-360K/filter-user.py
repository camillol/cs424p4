#!/usr/bin/env python

def filter_profile():
	with open("usersha1-profile.tsv") as f:
		with open("userid-profile.tsv", "w") as out:
			for n, line in enumerate(f):
				hash, gender, age, country, registered = line.split("\t")
				out.write("%d\t%s\t%s\t%s\t%s" % (n+1, gender, age, country, registered))

def filter_favorites():
	with open("usersha1-artmbid-artname-plays.tsv") as f:
		with open("userid-artmbid-artname-plays.tsv", "w") as out:
			with open("userid-artmbid-artname-plays-rejects.tsv", "w") as reject:
				n = 0
				lastuserhash = ""
				for line in f:
					userhash, artmbid, artname, plays = line.split("\t")
					if len(userhash) == 40:
						if userhash != lastuserhash:
							n += 1
							lastuserhash = userhash
						out.write("%d\t%s\t%s\t%s" % (n, artmbid, artname, plays))
					else:
						reject.write(line)

filter_profile()
filter_favorites()
