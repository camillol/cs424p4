#!/usr/bin/env python
# run filter-user.py first, then do
# sort -t "$(printf '\t')" -k 2,3 < userid-artmbid-artname-plays.tsv > userid-artmbid-artname-plays-sortbyart.tsv

from collections import defaultdict

def write_artist(artf, multif, art_id, art_mbid, art_names):
	_, name = max((v,k) for k,v in art_names.items())
	if len(art_names) > 1:
		for name, count in art_names.items():
			multif.write("%d\t%d\t%s\n" % (art_id, count, name))
	artf.write("%d\t%s\t%s\n" % (art_id, art_mbid, name))

def filter_favorite_artists():
	with open("userid-artmbid-artname-plays-sortbyart.tsv") as f:
		with open("userid-artid-plays.tsv", "w") as favf:
			with open("artid-artmbid-artname.tsv", "w") as artf:
				with open("artid-namecount-artname-multinames.tsv", "w") as multif:
					with open("artid-badmbid-artname", "w") as badf:
						n = 0
						lastart_ref = None
						for line in f:
							userid, artmbid, artname, plays = line.split("\t")
							artmbid = artmbid.strip()
							artmbid = artmbid.strip(".")
							if artmbid: art_ref = artmbid
							else: art_ref = artname
							if art_ref != lastart_ref:
								if lastart_ref:
									write_artist(artf, multif, n, lastart_mbid, lastart_names)
								n += 1
								lastart_ref = art_ref
								lastart_mbid = artmbid
								lastart_names = defaultdict(int)
								if artmbid and len(artmbid) != 36:
									badf.write("%d\t%s\t%s\n" % (n, artmbid, artname))
							lastart_names[artname] += 1
							favf.write("%s\t%d\t%s" % (userid, n, plays))
						if lastart_ref:
							write_artist(artf, multif, n, lastart_mbid, lastart_names)

filter_favorite_artists()
