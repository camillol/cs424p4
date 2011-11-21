#!/usr/bin/env python

def write_command(code, name):
	name = name.strip().replace('\\', '\\\\').replace("'","''")
	print "update countries set code='%s' where lower(name)='%s';" % (code, name.lower())


with open("country-codes.txt") as codef:
	for line in codef:
		code, name = line.split('   ')
		code = code.lower()
		if len(code) > 2: continue
		write_command(code, name)

for code, name in [
('cd', 'Congo, the Democratic Republic of the'),
('ci', "Cote D'Ivoire"),
('hr', 'Croatia'),
('va', 'Holy See (Vatican City State)'),
('ir', 'Iran, Islamic Republic of'),
('kp', "Korea, Democratic People's Republic of"),
('kr', "Korea, Republic of"),
('la', "Lao People's Democratic Republic"),
('ly', "Libyan Arab Jamahiriya"),
('fm', "Micronesia, Federated States of"),
('me', "Montenegro"),
('nz', "New Zealand"),
('ps', "Palestinian Territory, Occupied"),
('rs', "Serbia"),
('gs', "South Georgia and the South Sandwich Islands"),
('sy', "Syrian Arab Republic"),
('tz', "Tanzania, United Republic of"),
('vg', "Virgin Islands, British"),
('vi', "Virgin Islands, U.s.")
	]:
	write_command(code, name)
